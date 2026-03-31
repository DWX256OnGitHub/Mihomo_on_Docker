# Mihomo MetaCubeXD Docker

基于 Docker 的 Mihomo 代理 + MetaCubeXD Web UI 一体化解决方案

---

## 简介

本项目将 [Mihomo](https://github.com/MetaCubeX/mihomo)（原 Clash.Meta）和 [MetaCubeXD](https://github.com/MetaCubeX/metacubexd) 集成到一个 Docker 容器中，提供代理服务和管理界面。

### 核心组件

- **Mihomo**: 基于 Clash.Meta 的代理内核
- **MetaCubeXD**: Web 管理面板
- **Nginx**: 提供前端 Web 服务
- **Alpine Linux**: 轻量级基础镜像

---

## 功能特性

- 预配置 Mihomo 和 MetaCubeXD
- 非 root 用户运行，提高安全性
- 容器健康检查
- 支持 linux/amd64, linux/arm64 架构
- GitHub Actions 自动构建
- 支持外部配置文件挂载
- 进程监控和优雅关闭

---

## 快速开始

### 方式一：Docker Compose

1. 创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  mihomo:
    image: ghcr.io/dwx256ongithub/mihomo-metacubexd:latest
    container_name: mihomo
    restart: unless-stopped
    ports:
      - "7890:7890"   # HTTP 代理
      - "7891:7891"   # HTTPS 代理
      - "9090:9090"   # API 端口
      - "8080:8080"   # Web UI
    volumes:
      - ./config:/config           # 配置文件目录
      - ./data:/root/.config/mihomo # 运行数据目录
    environment:
      - TZ=Asia/Shanghai
```

2. 准备配置文件：

在 `./config` 目录下创建 `config.yaml`

3. 启动服务：

```bash
docker-compose up -d
```

4. 访问 Web UI：

浏览器打开 `http://localhost:8080`

### 方式二：Docker 命令

```bash
docker run -d \
  --name mihomo \
  --restart unless-stopped \
  -p 7890:7890 \
  -p 7891:7891 \
  -p 9090:9090 \
  -p 8080:8080 \
  -v $(pwd)/config:/config \
  -v $(pwd)/data:/root/.config/mihomo \
  -e TZ=Asia/Shanghai \
  ghcr.io/dwx256ongithub/mihomo-metacubexd:latest
```

---

## 配置说明

### 配置文件位置

| 路径 | 用途 |
|------|------|
| `/config/config.yaml` | Mihomo 配置文件（从宿主的 /config 挂载） |
| `/root/.config/mihomo` | Mihomo 运行数据目录 |

### 配置文件示例

```yaml
# config.yaml
mixed-port: 7890
allow-lan: true
mode: rule
log-level: info

external-controller: 0.0.0.0:9090
external-ui: /usr/share/nginx/html

proxies: []
proxy-groups: []
rules: []
```

更多配置选项请参考 [Mihomo 文档](https://wiki.metacubex.one/)

---

## 端口说明

| 端口 | 协议 | 用途 |
|------|------|------|
| `7890` | TCP | HTTP 代理端口 |
| `7891` | TCP | HTTPS 代理端口 |
| `9090` | TCP | Mihomo API 控制端口 |
| `8080` | TCP | MetaCubeXD Web UI 端口 |

### 浏览器代理设置

- HTTP Proxy: `host_ip:7890`
- HTTPS Proxy: `host_ip:7890`

---

## 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `TZ` | `UTC` | 时区设置，例如：`Asia/Shanghai` |

以下环境变量在构建时通过 build-arg 指定：

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `MIHOMO_VERSION` | `latest` | Mihomo 版本 |
| `METACUBEXD_VERSION` | `gh-pages` | MetaCubeXD 版本 |

### 自定义版本构建

```bash
docker build \
  --build-arg MIHOMO_VERSION=v1.18.0 \
  --build-arg METACUBEXD_VERSION=v2.8.0 \
  -t mihomo:custom \
  .
```

---

## 数据持久化

建议挂载以下目录：

```yaml
volumes:
  - ./config:/config                    # 配置文件
  - ./data:/root/.config/mihomo         # 运行数据（订阅、日志等）
```

---

## 健康检查

容器内置健康检查，配置如下：

- 检查间隔：30 秒
- 超时时间：10 秒
- 启动宽限期：5 秒
- 最大重试次数：3 次

查看健康状态：

```bash
# 查看容器健康状态
docker inspect --format='{{.State.Health.Status}}' mihomo
```

---

## 常见问题

### 1. 无法访问 Web UI

检查容器状态和日志：

```bash
# 检查容器是否运行
docker ps | grep mihomo

# 查看容器日志
docker logs mihomo

# 检查端口是否被占用
netstat -tlnp | grep :8080
```

### 2. 配置文件不生效

- 确保配置文件位于 `/config/config.yaml`
- 检查 YAML 语法是否正确
- 重启容器：`docker-compose restart`

### 3. 代理无法连接

```bash
# 测试 API 是否可访问
curl http://localhost:9090/proxies

# 检查防火墙设置
ufw status

# 验证配置文件
docker exec mihomo mihomo -t -d /root/.config/mihomo
```

### 4. ARM 设备使用

本项目支持以下架构：

- linux/amd64 (x86_64)
- linux/arm64 (aarch64)

ARM v7 (armv7l) 架构需要在构建时指定。

### 5. 更新镜像

```bash
# 拉取最新镜像
docker pull ghcr.io/dwx256ongithub/mihomo-metacubexd:latest

# 重新创建容器
docker-compose up -d --force-recreate

# 清理旧镜像
docker image prune -f
```

---

## 构建镜像

### 本地构建

```bash
# 构建默认版本
docker build -t mihomo-metacubexd:latest .

# 构建特定版本
docker build \
  --build-arg MIHOMO_VERSION=v1.18.0 \
  --build-arg METACUBEXD_VERSION=v2.8.0 \
  -t mihomo-metacubexd:v1.18.0 .
```

### 多平台构建

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t mihomo-metacubexd:latest \
  --push \
  .
```

---

## Web UI 使用

1. 访问 `http://your_host:8080`
2. 上传配置文件或使用 External Controller 连接
3. 在 Proxies 页面选择节点
4. 在 Rules 页面查看规则匹配
5. 在 Connections 页面查看活动连接

---

## 安全建议

1. 修改默认端口，减少被扫描的风险
2. 在配置文件中设置认证密钥
3. 使用防火墙限制 API 端口访问
4. 定期更新镜像和配置
5. 检查日志文件

### 配置认证

```yaml
# config.yaml
authentication:
  - "user1:password1"
  - "user2:password2"

secret: "your-secret-token"
```

---

## 资源限制

在 docker-compose.yml 中限制资源：

```yaml
services:
  mihomo:
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 128M
```

---

## 项目结构

```
.
├── Dockerfile              # Docker 镜像定义
├── entrypoint.sh           # 容器启动脚本
├── nginx.conf              # Nginx 配置
├── README.md               # 本文档
└── .github/workflows/
    └── docker.yml          # GitHub Actions 工作流
```

---

## 相关链接

- [Mihomo GitHub](https://github.com/MetaCubeX/mihomo)
- [MetaCubeXD GitHub](https://github.com/MetaCubeX/metacubexd)
- [Clash.Meta 配置文档](https://wiki.metacubex.one/)
- [Docker 官方文档](https://docs.docker.com/)

---

## 许可证

本项目使用的组件：

- Mihomo: MIT License
- MetaCubeXD: MIT License
- Nginx: BSD-like License
- Alpine Linux: MIT License

---

<div align="center">

如果这个项目对你有帮助，请给一个 Star 支持！

</div>
