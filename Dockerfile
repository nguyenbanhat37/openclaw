# Giai đoạn Build
FROM node:22 AS builder
RUN apt-get update && apt-get install -y python3 make g++ curl && rm -rf /var/lib/apt/lists/*
RUN npm install -g openclaw@beta --unsafe-perm

# Giai đoạn Runtime
FROM node:22-slim
WORKDIR /app

# Cài đặt công cụ hỗ trợ và tải trực tiếp ttyd
RUN apt-get update && apt-get install -y \
    procps \
    net-tools \
    curl \
    && curl -Lo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw

# Biến môi trường
ENV PORT=18789 \
    TTYD_PORT=7681

# Mở cổng cho Terminal
EXPOSE 18789 7681

# Chạy song song ttyd và OpenClaw
# ttyd sẽ chạy ở cổng 7681
CMD ["sh", "-c", "ttyd -p 7681 bash & node $(find /usr/local/lib/node_modules/openclaw -name 'index.js' | grep 'server' | head -n 1) gateway run --auth password --password admin123456 --bind 0.0.0.0 --allow-unconfigured"]
