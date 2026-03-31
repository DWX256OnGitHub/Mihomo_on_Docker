FROM alpine:3.20

ARG MIHOMO_VERSION=latest
ARG METACUBEXD_VERSION=gh-pages

WORKDIR /app

RUN apk add --no-cache \
    bash \
    curl \
    wget \
    tar \
    gzip \
    unzip \
    nginx \
    ca-certificates \
    tzdata && \
    rm -rf /var/cache/apk/*

# 创建非 root 用户
RUN addgroup -g 1000 mihomo && \
    adduser -D -u 1000 -G mihomo mihomo

# 下载 Mihomo
RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
      x86_64) MIHOMO_ARCH="linux-amd64" ;; \
      aarch64) MIHOMO_ARCH="linux-arm64" ;; \
      armv7l) MIHOMO_ARCH="linux-armv7" ;; \
      *) echo "Unsupported arch: $ARCH"; exit 1 ;; \
    esac; \
    if [ "$MIHOMO_VERSION" = "latest" ]; then \
      URL=$(wget -qO- https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | grep browser_download_url | grep "$MIHOMO_ARCH" | grep -v ".gz.asc" | grep ".gz" | head -n1 | cut -d '"' -f 4); \
    else \
      URL=$(wget -qO- "https://api.github.com/repos/MetaCubeX/mihomo/releases/tags/$MIHOMO_VERSION" | grep browser_download_url | grep "$MIHOMO_ARCH" | grep -v ".gz.asc" | grep ".gz" | head -n1 | cut -d '"' -f 4); \
    fi; \
    echo "Downloading Mihomo from: $URL"; \
    wget -O /tmp/mihomo.gz "$URL"; \
    gunzip /tmp/mihomo.gz; \
    mv /tmp/mihomo /usr/local/bin/mihomo; \
    chmod +x /usr/local/bin/mihomo; \
    rm -f /tmp/mihomo.gz

# 下载 MetaCubeXD
RUN set -eux; \
    mkdir -p /usr/share/nginx/html; \
    if [ "$METACUBEXD_VERSION" = "gh-pages" ]; then \
      wget -O /tmp/metacubexd.zip https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip; \
    else \
      wget -O /tmp/metacubexd.zip "https://github.com/MetaCubeX/metacubexd/archive/refs/tags/$METACUBEXD_VERSION.zip"; \
    fi; \
    unzip /tmp/metacubexd.zip -d /tmp; \
    cp -r /tmp/metacubexd-*/. /usr/share/nginx/html/; \
    rm -rf /tmp/metacubexd* /tmp/metacubexd.zip

RUN mkdir -p /root/.config/mihomo /run/nginx && \
    chown -R mihomo:mihomo /root/.config/mihomo

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# 设置目录权限
RUN chown -R mihomo:mihomo /app && \
    chown -R mihomo:mihomo /usr/share/nginx/html && \
    chown -R mihomo:mihomo /run/nginx && \
    chown mihomo:mihomo /entrypoint.sh

USER mihomo

EXPOSE 7890 7891 9090 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

ENTRYPOINT ["/entrypoint.sh"]