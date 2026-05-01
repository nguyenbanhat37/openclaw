# Sử dụng bản build có đầy đủ công cụ
FROM node:22 AS builder

# Cài đặt thêm các thư viện hệ thống cần thiết cho bản Beta
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Cài đặt OpenClaw bản BETA
RUN curl -fsSL https://openclaw.ai/install.sh | bash -s -- --beta

# --- KHU VỰC CAN THIỆP SÂU (CUSTOMIZATION) ---
WORKDIR /usr/local/lib/node_modules/openclaw

# 1. Tắt vĩnh viễn Pairing (Dành cho bản Beta)
RUN if [ -f dist/server/auth/pairing.js ]; then \
    echo "module.exports = { check: () => true, verify: () => true };" > dist/server/auth/pairing.js; \
    fi

# 2. Thay đổi System Prompt mặc định (Não bộ của AI)
# Giúp AI biết nó là một bản đã được bạn tùy chỉnh sâu
RUN sed -i 's/You are OpenClaw/You are a specialized Software Engineering Assistant/g' dist/server/config/prompts.js || echo "Skip prompt mod"

# 3. Đóng gói các thay đổi vào một file thực thi duy nhất
RUN npm prune --production
# --- KẾT THÚC KHU VỰC CAN THIỆP ---

# Giai đoạn chạy: Chỉ giữ lại những thứ cần thiết
FROM node:22-slim
WORKDIR /app

COPY --from=builder /usr/local/lib/node_modules/openclaw /usr/local/lib/node_modules/openclaw
RUN ln -s /usr/local/lib/node_modules/openclaw/bin/openclaw /usr/local/bin/openclaw

# Thiết lập biến môi trường để bypass mọi rào cản
ENV OPENCLAW_AUTH_MODE=password \
    OPENCLAW_DISABLE_PAIRING=true \
    OPENCLAW_BETA_ACCESS=true \
    NODE_ENV=production \
    PORT=18789

EXPOSE 18789

# Khởi chạy bản Beta với chế độ bỏ qua cấu hình ban đầu
CMD ["openclaw", "gateway", "run", "--auth", "password", "--bind", "0.0.0.0", "--allow-unconfigured"]
