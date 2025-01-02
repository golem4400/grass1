#!/bin/bash

SERVICE_FILE="/etc/systemd/system/getgrass.service"
PYTHON_PATH="/usr/bin/python3"
SCRIPT_PATH="/app/main.py"
WORKING_DIR="/app"

# 检查脚本文件是否存在
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "错误: $SCRIPT_PATH 文件不存在。请检查路径并重试。"
    exit 1
fi

# 创建 systemd 服务文件
echo "正在创建服务文件..."

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

echo "服务文件已创建: $SERVICE_FILE"

# 重新加载 systemd 守护进程
echo "重新加载 systemd 守护进程..."
systemctl daemon-reload

# 启动并启用服务
echo "启动 grass 服务..."
systemctl start getgrass.service

echo "将 grass 服务设为开机启动..."
systemctl enable getgrass.service

# 检查服务状态
echo "检查服务状态..."
systemctl status getgrass.service --no-pager

echo "设置完成。grass 服务已设置为开机启动。"
