# ... (Phần cài đặt ở trên giữ nguyên)

# Ví dụ: Can thiệp sâu vào code sau khi cài xong
RUN cd /usr/local/lib/node_modules/openclaw && \
    # 1. Đổi tên ứng dụng trong toàn bộ file client
    grep -rl "OpenClaw" dist/client | xargs sed -i 's/OpenClaw/MyPrivateAI/g' && \
    # 2. Tắt thông báo cập nhật gây phiền nhiễu
    sed -i 's/checkUpdates: true/checkUpdates: false/g' dist/server/config.js

# Thiết lập thư mục lưu trữ dữ liệu bền vững
VOLUME /root/.openclaw

# Lệnh chạy với cờ debug để bạn soi lỗi sâu hơn
CMD ["openclaw", "gateway", "run", "--auth", "password", "--bind", "0.0.0.0", "--loglevel", "debug"]
