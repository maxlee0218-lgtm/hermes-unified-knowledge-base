# 111服务器连接指引

## 服务器信息

| 项目 | 值 |
|------|-----|
| 主机 | 111.229.153.11 |
| 用户 | ubuntu |
| 连接方式 | SSH密钥（私钥在 ~/.ssh/id_rsa） |
| 用途 | 跳板机 + 数仓监控 |

## 关键目录

| 目录/文件 | 说明 |
|-----------|------|
| `/home/ubuntu/.hermes/hermes-agent/` | Hermes Agent 代码目录 |
| `/home/ubuntu/.hermes/profiles/infra/hermes-agent/venv/` | Python 虚拟环境 |
| `~/.hermes/config.yaml` | Hermes 主配置 |
| `~/.hermes/.env` | 环境变量（API Key等） |
| `/var/log/hermes/gateway.log` | Gateway 运行日志 |
| `/home/ubuntu/.clawai/clawpilot.log` | PocketClaw relay 日志 |
| `/etc/systemd/system/hermes-gateway.service` | Gateway systemd 服务 |

## 当前状态

- **版本**: v0.13.0 (2026.5.7)
- **Gateway**: systemd 管理
- **clawpilot**: pm2 管理
- **PocketClaw**: Relay connected, Hermes API connected

## 常用命令

```bash
# 查看 Gateway 状态
sudo systemctl status hermes-gateway

# 重启 Gateway
sudo systemctl restart hermes-gateway

# 查看 clawpilot 状态
clawpilot status

# 查看 Gateway 日志
tail -f /var/log/hermes/gateway.log

# 查看 clawpilot 日志
tail -f /home/ubuntu/.clawai/clawpilot.log

# 测试 API 连通性
curl http://127.0.0.1:8642/health

# 重启 clawpilot
clawpilot restart

# 查看 pm2 进程
pm2 list
```

## PocketClaw 连接验证

执行 `clawpilot status`，应显示：

```
Runtime      : hermes
Relay        : ✓ connected
Hermes API   : ✓ connected
```

## 修复记录

- [2026-05-08] 升级 v0.10.0 → v0.13.0
- [2026-05-08] 修复 Kanban 数据库迁移错误
- [2026-05-08] 修复 Cron 定时任务报错
- [2026-05-08] 配置飞书平台
- [2026-05-08] API Key 移至 .env
- [2026-05-08] 启用 session_search
- [2026-05-08] 清理冗余人格配置
- [2026-05-08] 配置日志错误监控定时器
- [2026-05-08] 修复 clawpilot hermes CLI 路径

## 注意事项

1. **venv 路径**: 实际使用的是 `/home/ubuntu/.hermes/profiles/infra/hermes-agent/venv/`，而非 `/home/ubuntu/.hermes/hermes-agent/venv/`
2. **hermes 命令**: 已创建 wrapper `/usr/local/bin/hermes`，指向正确的 venv
3. **API Key**: 存储在 `~/.hermes/.env` 中，config.yaml 中使用 `${KIMI_API_KEY}` 引用
4. **日志轮转**: `/etc/logrotate.d/hermes-gateway` 配置，50M×5轮
