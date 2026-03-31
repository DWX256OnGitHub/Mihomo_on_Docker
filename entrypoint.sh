#!/bin/sh
set -e

CONFIG_FILE="/root/.config/mihomo/config.yaml"

if [ -f /config/config.yaml ]; then
    cp /config/config.yaml "$CONFIG_FILE"
fi

echo "Starting Mihomo..."
/usr/local/bin/mihomo -d /root/.config/mihomo &
MIHOMO_PID=$!

echo "Starting Nginx..."
nginx -g 'daemon off;' &
NGINX_PID=$!

trap "echo 'Stopping...'; kill $MIHOMO_PID $NGINX_PID; exit 0" SIGTERM SIGINT

wait $MIHOMO_PID $NGINX_PID