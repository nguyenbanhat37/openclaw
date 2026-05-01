FROM node:22-slim

# 1. Cài đặt các thư viện hệ thống cần thiết cho các module node (như sharp, sqlite)
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt trực tiếp OpenClaw qua npm
# Sử dụng --unsafe-perm để tránh lỗi phân quyền khi cài global trong Docker
RUN npm install -g openclaw@stable --unsafe-perm

# 3. Thiết lập môi trường làm việc
WORKDIR /root/.openclaw

# Các biến môi trường "quyền lực" để bypass Pairing
ENV OPENCLAW_AUTH_MODE=password
ENV OPENCLAW_PASSWORD=admin123456
ENV OPENCLAW_DISABLE_PAIRING=true
ENV HOST=0.0.0.0
ENV PORT=18789

# Mở cổng
EXPOSE 18789

# 4. Khởi chạy với cấu hình ép buộc
CMD ["openclaw", "gateway", "run", "--auth", "password", "--password", "admin123456", "--bind", "0.0.0.0"]
