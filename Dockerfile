FROM openclaw/gateway:v2-latest

# Thiết lập thư mục làm việc
WORKDIR /root/.openclaw

# Thiết lập các biến môi trường để bypass Pairing và cấu hình Auth
ENV OPENCLAW_AUTH_MODE=password
ENV OPENCLAW_PASSWORD=admin123456
ENV OPENCLAW_DISABLE_PAIRING=true
ENV OPENCLAW_BIND_HOST=0.0.0.0
ENV OPENCLAW_TRUST_PROXY=true

# Port mặc định của OpenClaw
EXPOSE 18789

# Lệnh khởi chạy tối ưu cho Railway
CMD ["openclaw", "gateway", "run", "--auth", "password", "--password", "admin123456", "--allow-unconfigured", "--bind", "auto"]