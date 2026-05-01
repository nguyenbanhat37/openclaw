FROM ghcr.io/openclaw/openclaw-gateway:v2-latest

# OpenClaw thường chạy dưới user root trong container
USER root
WORKDIR /root/.openclaw

# Thiết lập biến môi trường ép buộc
ENV OPENCLAW_AUTH_MODE=password
ENV OPENCLAW_PASSWORD=admin123456
ENV OPENCLAW_DISABLE_PAIRING=true
ENV HOST=0.0.0.0
ENV PORT=18789

# Mở cổng
EXPOSE 18789

# Lệnh chạy tối giản nhưng mạnh mẽ
CMD ["openclaw", "gateway", "run", "--auth", "password", "--password", "admin123456", "--bind", "0.0.0.0"]
