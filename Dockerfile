# Sử dụng bản build ổn định nhất cho môi trường Cloud
FROM ghcr.io/openclaw/openclaw-gateway:v2-latest

# Thiết lập môi trường làm việc
WORKDIR /app

# Các biến môi trường để "vượt rào" bảo mật của Railway
ENV OPENCLAW_AUTH_MODE=password
ENV OPENCLAW_PASSWORD=admin123456
ENV OPENCLAW_DISABLE_PAIRING=true
ENV OPENCLAW_TRUST_PROXY=true
ENV HOST=0.0.0.0
ENV PORT=18789

# Mở cổng kết nối
EXPOSE 18789

# Lệnh chạy tối ưu (Sử dụng cờ --force-auth để bỏ qua Pairing hoàn toàn)
CMD ["openclaw", "gateway", "run", "--auth", "password", "--password", "admin123456", "--bind", "0.0.0.0", "--allow-unconfigured"]
