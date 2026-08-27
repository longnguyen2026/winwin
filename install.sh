#!/usr/bin/env bash
set -e

# Link Raw 
SETUP_URL="https://raw.githubusercontent.com/longnguyen2026/winwin/main/setup.sh"

echo "=========================================="
echo "    KIỂM TRA CẤU HÌNH HỆ THỐNG MÁY CHỦ    "
echo "=========================================="

# 1. Kiểm tra kiến trúc hệ điều hành (chỉ nhận x86_64)
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    echo "[-] Lỗi: Kiến trúc $ARCH không được hỗ trợ. Cần x86_64."
    exit 1
fi

# 2. Kiểm tra hỗ trợ ảo hóa CPU (VT-x / AMD-V)
if grep -E -q '(vmx|svm)' /proc/cpuinfo; then
    echo "[+] CPU hỗ trợ ảo hóa phần cứng (VT-x/AMD-V): OK"
else
    echo "[-] Cảnh báo: CPU không hỗ trợ hoặc chưa bật Virtualization trong BIOS!"
    read -p "Bạn có muốn tiếp tục chạy chế độ không KVM (hiệu năng sẽ chậm)? (y/N): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        exit 1
    fi
fi

# 3. Kiểm tra dung lượng RAM (Khuyến nghị tối thiểu 3.5GB)
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_KB / 1024 / 1024))
if [ "$TOTAL_RAM_GB" -lt 4 ]; then
    echo "[-] Cảnh báo: RAM hệ thống ($TOTAL_RAM_GB GB) dưới mức tối ưu (>= 4GB)."
else
    echo "[+] Bộ nhớ RAM ($TOTAL_RAM_GB GB): OK"
fi

# 4. Kiểm tra dung lượng ổ cứng trống (Tối thiểu 30GB)
FREE_DISK_GB=$(df -k "$HOME" | awk 'NR==2 {print int($4/1024/1024)}')
if [ "$FREE_DISK_GB" -lt 30 ]; then
    echo "[-] Lỗi: Dung lượng ổ cứng khả dụng ($FREE_DISK_GB GB) không đủ tối thiểu 30GB."
    exit 1
else
    echo "[+] Dung lượng ổ đĩa trống ($FREE_DISK_GB GB): OK"
fi

echo "=========================================="
echo "[+] Cấu hình đạt yêu cầu. Đang nạp gói cài đặt..."

# 5. Tải và thực thi setup.sh trong bộ nhớ tạm, tự hủy khi kết thúc
TMP_SETUP=$(mktemp /tmp/setup_win_XXXXXX.sh)
trap 'rm -f "$TMP_SETUP"' EXIT INT TERM

# Tải setup.sh về file tạm
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SETUP_URL" -o "$TMP_SETUP"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_SETUP" "$SETUP_URL"
else
    sudo apt update && sudo apt install -y curl
    curl -fsSL "$SETUP_URL" -o "$TMP_SETUP"
fi

chmod +x "$TMP_SETUP"

# Thực thi file setup lõi
bash "$TMP_SETUP"
