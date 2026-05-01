# Sử dụng Node 22 bản đầy đủ để tránh thiếu hụt công cụ build
FROM node:22 AS builder

# Cài đặt các thư viện cần thiết để biên dịch (Native Modules)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt trực tiếp bản Beta qua NPM (Bypass lỗi TTY của script install.sh)
# Sử dụng tag @beta để lấy bản 2026.4.x
RUN npm install -g openclaw@beta --unsafe-perm

# --- KHU VỰC CAN THIỆP SÂU ---
WORKDIR /usr/local/lib/node_modules/openclaw

# 1. Tắt vĩnh viễn Pairing (Dành cho bản Beta 2026)
# Chúng ta can thiệp vào file cấu hình mặc định để ép disablePairing = true
RUN if [ -f dist/server/config/default.js ]; then \
    sed -i 's/disablePairing: false/disablePairing: true/g' dist/server/config/default.js; \
    fi

# 2. Xóa bỏ yêu cầu mật khẩu khởi tạo nếu cần (Tùy chỉnh sâu)
RUN sed -i 's/requireSetup: true/requireSetup: false/g' dist/server/config/default.js || echo "Skip setup bypass"
# --- KẾT THÚC CAN THIỆP ---

# Giai đoạn Runtime (Sạch và Nhẹ)
FROM node:22-slim
WORKDIR /app

# 1. Copy toàn bộ package từ builder
COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw

# 2. Thiết lập biến môi trường
ENV OPENCLAW_AUTH_MODE=password \
    OPENCLAW_PASSWORD=admin123456 \
    OPENCLAW_DISABLE_PAIRING=true \
    PORT=18789 \
    HOST=0.0.0.0 \
    NODE_ENV=production

EXPOSE 18789

# 3. Lệnh khởi chạy trực tiếp vào "nhân" của server
# Trong bản Beta 2026, file chính thường nằm ở dist/server/main.js hoặc dist/server/index.js
CMD ["node", "/usr/local/lib/node_modules/openclaw/dist/server/index.js", "gateway", "run", "--auth", "password", "--password", "admin123456", "--bind", "0.0.0.0", "--allow-unconfigured"]
