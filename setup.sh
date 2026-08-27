#!/usr/bin/env bash
set -e

echo "[+] 1/4 Cài đặt gói Docker Engine, Docker Compose và QEMU-KVM..."
sudo apt update -qq
sudo apt install -y -qq docker.io docker-compose-v2 qemu-kvm curl

echo "[+] 2/4 Thiết lập quyền và nạp kernel module KVM..."
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

sudo modprobe kvm || true
if grep -q "vmx" /proc/cpuinfo; then
    sudo modprobe kvm_intel || true
elif grep -q "svm" /proc/cpuinfo; then
    sudo modprobe kvm_amd || true
fi

echo "[+] 3/4 Khởi tạo môi trường Docker compose..."
TARGET_DIR="$HOME/windows-docker"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

cat << 'EOF' > compose.yaml
services:
  windows:
    image: ghcr.io/dockur/windows
    container_name: windows
    environment:
      VERSION: "10"
      RAM_SIZE: "4G"
      CPU_CORES: "2"
      DISK_SIZE: "32G"
    devices:
      - /dev/kvm
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    volumes:
      - ./win_data:/storage
      - ~/Downloads:/shared
    restart: on-failure
    stop_grace_period: 2m
EOF

echo "[+] 4/4 Khởi chạy máy ảo ngầm..."
sudo docker compose up -d

echo ""
echo "=========================================================="
echo " [OK] KHỞI TẠO MÁY ẢO THÀNH CÔNG!"
echo " - Truy cập Web GUI : http://localhost:8006"
echo " - Truy cập RDP     : localhost:3389 (User: docker | Pass: để trống)"
echo " - Xem log cài đặt  : cd ~/windows-docker && sudo docker compose logs -f"
echo "=========================================================="
