# Giai đoạn 1: Builder để cài đặt openclaw từ npm
FROM node:22 AS builder
RUN apt-get update && apt-get install -y python3 make g++ curl && rm -rf /var/lib/apt/lists/*
RUN npm install -g openclaw@beta --unsafe-perm

# Giai đoạn 2: Runtime
FROM node:22-slim
WORKDIR /app

# Cài đặt công cụ và tải ttyd trực tiếp
RUN apt-get update && apt-get install -y \
    curl \
    procps \
    && curl -Lo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd \
    && rm -rf /var/lib/apt/lists/*

# Copy từ builder nội bộ (Thay vì copy từ ghcr.io)
COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw

# Thiết lập Port cho ttyd
ENV PORT=7681
EXPOSE 7681

# Lệnh khởi chạy chỉ ttyd để kiểm tra log
# Thêm -W để ttyd có quyền ghi, giúp tránh một số lỗi đẩy ra stderr (vạch đỏ)
CMD ["ttyd", "-p", "7681", "-W", "bash"]
