#!/bin/bash

SERVICE_FILE="/etc/systemd/system/getgrass.service"
PYTHON_PATH="/usr/bin/python3"
SCRIPT_PATH="/root/main.py"
WORKING_DIR="/root/grass1"

#"Kiểm tra xem tệp script có tồn tại hay không"
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Lỗi: Tệp $SCRIPT_PATH không tồn tại. Vui lòng kiểm tra lại đường dẫn và thử lại."
    exit 1
fi

"Tạo tệp dịch vụ systemd".
echo "Đang tạo tệp dịch vụ systemd..."

cat > $SERVICE_FILE <<EOL
[Unit]
Description=Grass Service
After=network.target

[Service]
ExecStart=$PYTHON_PATH $SCRIPT_PATH
Restart=always
User=root
WorkingDirectory=$WORKING_DIR

[Install]
WantedBy=multi-user.target
EOL

echo "Tệp dịch vụ đã được tạo: $SERVICE_FILE"

# Tải lại tiến trình systemd
echo "Đang tải lại tiến trình systemd..."
systemctl daemon-reload

# Khởi động và bật dịch vụ
echo "Đang khởi động dịch vụ grass..."
systemctl start getgrass.service

echo "Đang thiết lập dịch vụ grass để tự động khởi động cùng hệ thống..."
systemctl enable getgrass.service

# Kiểm tra trạng thái dịch vụ
echo "Đang kiểm tra trạng thái dịch vụ..."
systemctl status getgrass.service --no-pager

echo "Cài đặt hoàn tất. Dịch vụ grass đã được thiết lập để tự động khởi động cùng hệ thống."