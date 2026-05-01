# Giai đoạn 1: Build (Nhà bếp)
FROM node:22-slim AS builder

# Cài đặt công cụ biên dịch để build các native modules (sqlite3, sharp)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt OpenClaw bản stable
RUN npm install -g openclaw@stable --unsafe-perm

# --- BẮT ĐẦU PHẪU THUẬT (CAN THIỆP SÂU) ---
WORKDIR /usr/local/lib/node_modules/openclaw

# 1. Tắt vĩnh viễn cơ chế Pairing bằng cách ghi đè logic kiểm tra
# Chúng ta ép hàm checkPairing luôn trả về true
RUN sed -i 's/async checkPairing(.*){/async checkPairing(){return true;/g' dist/server/services/auth.js || echo "Skip logic bypass"

# 2. Rebrand - Đổi tên hiển thị từ "OpenClaw" thành tên riêng của bạn (ví dụ: "ProDev AI")
RUN grep -rl "OpenClaw" dist/client | xargs sed -i 's/OpenClaw/ProDev AI/g' || echo "Skip rebrand"

# 3. Tắt thông báo cập nhật (Update Check) để server chạy ổn định, không gọi về nhà
RUN sed -i 's/checkUpdates: true/checkUpdates: false/g' dist/server/config/default.js || echo "Skip config fix"
# --- KẾT THÚC PHẪU THUẬT ---


# Giai đoạn 2: Chạy (Bàn ăn) - Giúp Image siêu nhẹ
FROM node:22-slim
WORKDIR /app

# Chỉ copy những gì đã "nấu" xong
COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw
RUN ln -s /usr/local/lib/node_modules/openclaw/bin/openclaw /usr/local/bin/openclaw

# Thiết lập thư mục dữ liệu (Dùng để mount Volume trên Railway nếu cần)
RUN mkdir -p /root/.openclaw

# Các biến môi trường mặc định (Có thể ghi đè trong tab Variables của Railway)
ENV OPENCLAW_AUTH_MODE=password \
    OPENCLAW_DISABLE_PAIRING=true \
    HOST=0.0.0.0 \
    PORT=18789

EXPOSE 18789

# Khởi chạy với quyền admin và chế độ allow-unconfigured để không bị kẹt ở màn hình setup
CMD ["openclaw", "gateway", "run", "--auth", "password", "--bind", "0.0.0.0", "--allow-unconfigured"]
