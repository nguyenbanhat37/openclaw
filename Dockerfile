# Giai đoạn Build
FROM node:22 AS builder
RUN apt-get update && apt-get install -y python3 make g++ curl && rm -rf /var/lib/apt/lists/*
RUN npm install -g openclaw@beta --unsafe-perm

# Giai đoạn Runtime
FROM node:22-slim
WORKDIR /app

# Cài đặt ttyd và các công cụ bổ trợ
RUN apt-get update && apt-get install -y \
    ttyd \
    procps \
    net-tools \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw

# Biến môi trường
ENV PORT=18789 \
    TTYD_PORT=7681

# Mở cả 2 cổng: 18789 (App) và 7681 (Terminal)
EXPOSE 18789 7681

# Script khởi chạy song song cả OpenClaw và ttyd
CMD ["sh", "-c", "ttyd -p 7681 bash & node $(find /usr/local/lib/node_modules/openclaw -name 'index.js' | grep 'server' | head -n 1) gateway run --auth password --password admin123456 --bind 0.0.0.0 --allow-unconfigured"]
