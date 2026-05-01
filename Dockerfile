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

# Giai đoạn Runtime
FROM node:22-slim
WORKDIR /app

# Copy toàn bộ thư mục package
COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw

# PHẪU THUẬT ĐƯỜNG DẪN: Kiểm tra và tạo link chuẩn
# Bản Beta đôi khi để file chạy trong mục 'dist/bin' hoặc 'bin'
RUN if [ -f /usr/local/lib/node_modules/openclaw/bin/openclaw ]; then \
        ln -s /usr/local/lib/node_modules/openclaw/bin/openclaw /usr/local/bin/openclaw; \
    else \
        ln -s /usr/local/lib/node_modules/openclaw/dist/bin/openclaw.js /usr/local/bin/openclaw; \
    fi && chmod +x /usr/local/bin/openclaw

# Thiết lập môi trường
ENV OPENCLAW_AUTH_MODE=password \
    OPENCLAW_PASSWORD=admin123456 \
    OPENCLAW_DISABLE_PAIRING=true \
    PORT=18789 \
    HOST=0.0.0.0

EXPOSE 18789

# Sử dụng lệnh khởi chạy trực tiếp bằng node để đảm bảo tính tương thích
CMD ["node", "/usr/local/lib/node_modules/openclaw/dist/server/index.js", "gateway", "run", "--auth", "password", "--bind", "0.0.0.0", "--allow-unconfigured"]
