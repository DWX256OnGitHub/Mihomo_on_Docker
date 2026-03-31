#!/bin/bash
set -e

CONFIG_FILE="/root/.config/mihomo/config.yaml"

# 复制配置文件（如果存在）
if [ -f /config/config.yaml ]; then
    echo "Found config file, copying to Mihomo..."
    cp /config/config.yaml "$CONFIG_FILE"
fi

# 清理函数
cleanup() {
    echo "Stopping services..."
    if [ -n "$MIHOMO_PID" ] && kill -0 $MIHOMO_PID 2>/dev/null; then
        kill -TERM $MIHOMO_PID
        wait $MIHOMO_PID 2>/dev/null || true
    fi
    if [ -n "$NGINX_PID" ] && kill -0 $NGINX_PID 2>/dev/null; then
        kill -TERM $NGINX_PID
        wait $NGINX_PID 2>/dev/null || true
    fi
    echo "All services stopped."
    exit 0
}

# 设置信号陷阱
trap cleanup SIGTERM SIGINT SIGHUP EXIT

# 启动 Mihomo
echo "Starting Mihomo..."
/usr/local/bin/mihomo -d /root/.config/mihomo &
MIHOMO_PID=$!

# 启动 Nginx
echo "Starting Nginx..."
nginx -g 'daemon off;' &
NGINX_PID=$!

# 监控进程
while true; do
    # 检查 Mihomo 是否存活
    if ! kill -0 $MIHOMO_PID 2>/dev/null; then
        echo "Mihomo process died unexpectedly (PID: $MIHOMO_PID)"
        cleanup
    fi
    
    # 检查 Nginx 是否存活
    if ! kill -0 $NGINX_PID 2>/dev/null; then
        echo "Nginx process died unexpectedly (PID: $NGINX_PID)"
        cleanup
    fi
    
    sleep 5
done