# Cài Win ảo
````Bash
bash <(curl -fsSL https://raw.githubusercontent.com/longnguyen2026/winwin/main/install.sh)
````


**Đúng, đường dẫn `http://localhost:8006/` là cố định** theo cấu hình bạn đã khai báo trong file `compose.yaml`. Nó sẽ không tự động thay đổi trừ khi bạn chủ động sửa cổng (port) hoặc truy cập từ thiết bị khác.

---

**1. Truy cập trên chính máy Linux Mint (Máy Host)**

* **Địa chỉ cố định:** Luôn là `http://localhost:8006` hoặc `[http://127.0.0.1:8006](http://127.0.0.1:8006)`.


* **Lý do:** Trong file `compose.yaml`, bạn đã gán cổng máy host với cổng container qua dòng:
```yaml
ports:
  - 8006:8006

```



---

**2. Truy cập từ máy khác trong cùng mạng LAN (Điện thoại, Laptop khác)**
Nếu bạn muốn dùng một máy khác cùng mạng Wi-Fi/LAN để mở màn hình Windows này, thay `localhost` bằng **IP nội bộ của máy Linux Mint**:

* Tìm IP máy Linux: Gõ lệnh `hostname -I` hoặc `ip a` (Ví dụ ra `192.168.1.50`).
* Mở trình duyệt trên máy khác và truy cập: `[http://192.168.1.50:8006](http://192.168.1.50:8006)`.

---

**3. Muốn đổi sang cổng khác (Ví dụ tránh trùng cổng hoặc thích cổng khác)**
Nếu muốn đổi sang cổng khác (ví dụ cổng `8888`), bạn chỉ cần mở file `~/windows-docker/compose.yaml` và sửa lại phần map port:

```yaml
    ports:
      - 8888:8006       # Đổi cổng bên ngoài máy host thành 8888, giữ nguyên cổng 8006 bên trong

```

Sau đó áp dụng thay đổi:

```bash
cd ~/windows-docker && docker compose up -d

```

Lúc này đường dẫn mới sẽ cố định là: `
