# Mihomo MetaCubeXD Docker

🚀 基于 Docker 的 Mihomo 代理 + MetaCubeXD Web UI 一体化解决方案

[![Docker Image Size](https://img.shields.io/docker/image-size/ghcr.io/mihomo-on-docker/mihomo-metacubexd/latest)](https://ghcr.io/mihomo-on-docker/mihomo-metacubexd)
[![Docker Pulls](https://img.shields.io/docker/pulls/ghcr.io/mihomo-on-docker/mihomo-metacubexd)](https://ghcr.io/mihomo-on-docker/mihomo-metacubexd)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/mihomo-on-docker/Mihomo_on_Docker/docker.yml)](https://github.com/mihomo-on-docker/Mihomo_on_Docker/actions)
[![License](https://img.shields.io/github/license/mihomo-on-docker/Mihomo_on_Docker)](https://github.com/mihomo-on-docker/Mihomo_on_Docker/blob/main/LICENSE)

---

## 📖 目录

- [简介](#-简介)
- [功能特性](#-功能特性)
- [快速开始](#-快速开始)
- [配置说明](#-配置说明)
- [端口说明](#-端口说明)
- [环境变量](#-环境变量)
- [数据持久化](#-数据持久化)
- [健康检查](#-健康检查)
- [常见问题](#-常见问题)
- [构建镜像](#-构建镜像)
- [许可证](#-许可证)

---

## 💡 简介

本项目将 [Mihomo](https://github.com/MetaCubeX/mihomo)（原 Clash.Meta）和 [MetaCubeXD](https://github.com/MetaCubeX/metacubexd) 集成到一个轻量级 Docker 容器中，提供简单易用的代理服务和现代化的 Web 管理界面。

### 核心组件

| 组件 | 说明 |
|------|------|
| **Mihomo** | 基于 Clash.Meta 的高性能代理内核 |
| **MetaCubeXD** | 美观易用的 Web 控制面板 |
| **Nginx** | 高性能 Web 服务器，提供前端服务 |
| **Alpine Linux** | 轻量级基础镜像，仅约 50MB |

---

## ✨ 功能特性

- 🎯 **开箱即用** - 预配置 Mihomo 和 MetaCubeXD，无需复杂安装
- 🔒 **安全运行** - 非 root 用户运行，降低安全风险
- 🏥 **健康检查** - 自动监控容器健康状态
- 📦 **多架构支持** - 支持 linux/amd64, linux/arm64, linux/arm/v7
- 🔄 **自动更新** - GitHub Actions 自动构建最新镜像
- 💾 **配置持久化** - 支持外部配置文件挂载
- 🌐 **反向代理** - Nginx 提供高效的 Web 服务
- 📊 **实时监控** - Web UI 实时显示连接和流量信息
- 🛡️ **信号处理** - 优雅关闭，避免数据丢失

---

## 🚀 快速开始

### 方式一：Docker Compose（推荐）

1. 创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  mihomo:
    image: ghcr.io/mihomo-on-docker/mihomo-metacubexd:latest
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
    networks:
      - mihomo_net

networks:
  mihomo_net:
    driver: bridge
```

2. 准备配置文件：

在 `./config` 目录下创建 `config.yaml`（可参考 [Mihomo 官方文档](https://wiki.metacubex.one/)）

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
  ghcr.io/mihomo-on-docker/mihomo-metacubexd:latest
```

---

## ⚙️ 配置说明

### 配置文件位置

| 路径 | 用途 | 是否必须 |
|------|------|----------|
| `/config/config.yaml` | Mihomo 配置文件 | 可选（首次启动会自动生成） |
| `/root/.config/mihomo` | Mihomo 运行数据 | 建议持久化 |

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

📝 **完整配置模板**: [Clash.Meta 配置文档](https://wiki.metacubex.one/config/)

---

## 🔌 端口说明

| 端口 | 协议 | 用途 | 说明 |
|------|------|------|------|
| `7890` | TCP | HTTP 代理 | 用于 HTTP/HTTPS 流量代理 |
| `7891` | TCP | HTTPS 代理 | 用于 HTTPS 流量代理（可选） |
| `9090` | TCP | API 控制 | MetaCubeXD 连接 Mihomo 的 API 接口 |
| `8080` | TCP | Web UI | 浏览器访问 MetaCubeXD 面板 |

### 浏览器代理设置

- **HTTP Proxy**: `host_ip:7890`
- **HTTPS Proxy**: `host_ip:7890`
- **SOCKS5 Proxy**: `host_ip:7890`（如启用 SOCKS）

---

## 🌍 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `TZ` | `UTC` | 时区设置，例如：`Asia/Shanghai` |
| `MIHOMO_VERSION` | `latest` | Mihomo 版本（构建时指定） |
| `METACUBEXD_VERSION` | `gh-pages` | MetaCubeXD 版本（构建时指定） |

### 自定义版本构建

```bash
docker build \
  --build-arg MIHOMO_VERSION=v1.18.0 \
  --build-arg METACUBEXD_VERSION=v2.8.0 \
  -t mihomo:custom \
  .
```

---

## 💾 数据持久化

建议挂载以下目录以保存数据：

```yaml
volumes:
  - ./config:/config                    # 配置文件
  - ./data:/root/.config/mihomo         # 订阅、日志等数据
```

### 目录结构

```
mihomo_data/
├── config/
│   └── config.yaml          # 主配置文件
└── data/
    ├── Country.mmdb         # GeoIP 数据库
    ├── logs/                # 日志文件
    └── cache/               # 缓存文件
```

---

## 🏥 健康检查

容器内置健康检查，每 30 秒检测一次 Web UI 可用性：

```bash
# 查看容器健康状态
docker inspect --format='{{.State.Health.Status}}' mihomo

# 查看详细健康日志
docker inspect --format='{{json .State.Health}}' mihomo | jq
```

### 健康检查参数

| 参数 | 值 | 说明 |
|------|-----|------|
| Interval | 30s | 检查间隔 |
| Timeout | 10s | 超时时间 |
| Start Period | 5s | 启动宽限期 |
| Retries | 3 | 最大重试次数 |

---

## ❓ 常见问题

### 1. 无法访问 Web UI

**解决方案**：
```bash
# 检查容器状态
docker ps | grep mihomo

# 查看容器日志
docker logs mihomo

# 检查端口占用
netstat -tlnp | grep :8080
```

### 2. 配置文件不生效

**解决方案**：
- 确保配置文件路径正确：`/config/config.yaml`
- 检查 YAML 语法是否正确
- 重启容器：`docker-compose restart`

### 3. 代理无法连接

**解决方案**：
```bash
# 测试 Mihomo API
curl http://localhost:9090/proxies

# 检查防火墙规则
ufw status

# 验证配置
docker exec mihomo mihomo -t -d /root/.config/mihomo
```

### 4. ARM 设备运行

本项目支持 ARM 架构（树莓派、NAS 等）：

```bash
# ARM64 设备
docker pull ghcr.io/mihomo-on-docker/mihomo-metacubexd:latest

# ARM v7 设备（需要单独构建）
docker build --platform linux/arm/v7 -t mihomo:arm .
```

### 5. 更新镜像

```bash
# 拉取最新镜像
docker pull ghcr.io/mihomo-on-docker/mihomo-metacubexd:latest

# 重新创建容器
docker-compose up -d --force-recreate

# 清理旧镜像
docker image prune -f
```

---

## 🛠️ 构建镜像

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
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t mihomo-metacubexd:latest \
  --push \
  .
```

---

## 📱 Web UI 使用指南

### 初次配置

1. 访问 `http://your_host:8080`
2. 点击 **"Configuration"** → **"Upload Config"**
3. 上传你的 `config.yaml` 文件
4. 或使用 **"External Controller"** 连接现有 Mihomo 实例

### 常用功能

| 功能 | 路径 | 说明 |
|------|------|------|
| 代理选择 | `/proxies` | 切换节点和策略组 |
| 规则查看 | `/rules` | 查看路由规则匹配 |
| 连接管理 | `/connections` | 实时监控活动连接 |
| 日志查看 | `/logs` | 查看 Mihomo 运行日志 |
| 配置管理 | `/configs` | 调整运行参数 |

---

## 🔐 安全建议

1. **修改默认端口** - 避免使用常见端口减少扫描
2. **启用认证** - 在配置文件中设置 `secret`
3. **限制访问** - 使用防火墙限制 API 端口访问
4. **定期更新** - 保持镜像和配置文件最新
5. **日志审计** - 定期检查访问日志

### 配置认证

```yaml
# config.yaml
authentication:
  - "user1:password1"
  - "user2:password2"

secret: "your-secret-token"
```

---

## 📊 性能优化

### 内存限制

```yaml
# docker-compose.yml
services:
  mihomo:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 128M
```

### CPU 限制

```yaml
services:
  mihomo:
    cpus: 1.0
    cpu_shares: 512
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

### 第三方组件许可证

- **Mihomo**: MIT License
- **MetaCubeXD**: MIT License
- **Nginx**: BSD-like License
- **Alpine Linux**: MIT License

---

## 🔗 相关链接

- [Mihomo GitHub](https://github.com/MetaCubeX/mihomo)
- [MetaCubeXD GitHub](https://github.com/MetaCubeX/metacubexd)
- [Clash.Meta 文档](https://wiki.metacubex.one/)
- [Docker Hub](https://hub.docker.com/)
- [GitHub Container Registry](https://ghcr.io/)

---

## 📮 联系方式

- 💬 Issues: [GitHub Issues](https://github.com/mihomo-on-docker/Mihomo_on_Docker/issues)
- 📧 Email: your-email@example.com
- 💬 Telegram: [讨论群组](https://t.me/your_group)

---

<div align="center">

**如果这个项目对你有帮助，请给一个 ⭐ Star 支持！**

Made with ❤️ by Mihomo on Docker Team

</div>
