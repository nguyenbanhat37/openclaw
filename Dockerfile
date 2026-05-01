FROM node:22-slim
WORKDIR /app

# Cài đặt các thư viện tối thiểu cần thiết cho ttyd chạy ổn định
RUN apt-get update && apt-get install -y \
    curl \
    procps \
    && curl -Lo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/1.7.3/ttyd.x86_64 \
    && chmod +x /usr/local/bin/ttyd \
    && rm -rf /var/lib/apt/lists/*

# Copy OpenClaw vào nhưng CHƯA CHẠY nó để tránh làm sập container
COPY --from=ghcr.io/openclaw/openclaw:beta /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw

ENV PORT=7681
EXPOSE 7681

# Chạy duy nhất ttyd ở chế độ đơn giản nhất
# Lệnh này sẽ giúp container luôn sống và log thường sẽ chuyển sang xanh
CMD ["ttyd", "-p", "7681", "-i", "0.0.0.0", "bash"]
