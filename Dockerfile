FROM node:20-slim

# Cài đặt các gói phụ trợ
RUN apt-get update && apt-get install -y curl ca-certificates bash && rm -rf /var/lib/apt/lists/*

# Cài đặt OpenClaw bản Stable từ domain .ai
RUN curl -fsSL https://openclaw.ai/install.sh | bash -s -- --version stable

# Thiết lập môi trường làm việc
WORKDIR /root/.openclaw
ENV OPENCLAW_AUTH_MODE=password
ENV OPENCLAW_PASSWORD=admin123456
ENV OPENCLAW_DISABLE_PAIRING=true
ENV HOST=0.0.0.0

# Railway sẽ gán cổng ngẫu nhiên, nên dùng biến $PORT
EXPOSE 18789

# Lệnh khởi chạy: Ép dùng password và bind tất cả IP
CMD openclaw gateway run --auth password --password $OPENCLAW_PASSWORD --bind 0.0.0.0 --allow-unconfigured
