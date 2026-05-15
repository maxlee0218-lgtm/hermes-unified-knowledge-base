# 150服务器连接指引

## 服务器信息

| 项目 | 值 |
|------|-----|
| 主机 | 150.242.81.21 |
| 端口 | 22（默认SSH） |
| 用户 | root |
| 连接方式 | 公网直接访问，无需VPN或跳板机 |
| 密钥 | ~/.ssh/id_ed25519 |

## SSH连接命令

```bash
ssh -i ~/.ssh/id_ed25519 root@150.242.81.21
```

## 关键目录

| 目录/文件 | 说明 |
|-----------|------|
| `/root/.hermes/hermes-agent/` | Hermes Agent代码 |
| `/root/.hermes/hermes-agent/venv/` | Python虚拟环境 |
| `~/.hermes/config.yaml` | 主配置 |
| `~/.hermes/.env` | API Keys |
| `/var/log/hermes/gateway.log` | Gateway日志 |
| `/opt/warehouse-monitor-v2/` | 数仓监控V2 |
| `/root/wiki/` | LLM Wiki知识库 |

## 当前状态

- **版本**: v0.12.0
- **Gateway**: systemd管理（`hermes-gateway.service`）
- **PocketClaw**: pm2管理（`clawpilot`）
- **状态**: Relay connected, Hermes API connected

## 常用命令

```bash
# 查看Gateway状态
sudo systemctl status hermes-gateway

# 重启Gateway
sudo systemctl restart hermes-gateway

# 查看clawpilot状态
clawpilot status

# 查看日志
tail -f /var/log/hermes/gateway.log
tail -f /home/ubuntu/.clawai/clawpilot.log

# 测试API
curl http://127.0.0.1:8642/health
```

## 升级注意事项

- 当前v0.12.0运行稳定
- v0.13.0需下载18MB文件，网络可能中断
- **升级前备份**: `cp -a /root/.hermes/hermes-agent /root/.hermes/hermes-agent-v0.12.0-backup`
- 升级失败时恢复备份即可

## 网络配置

- 公网IP: 150.242.81.21
- 内网IP: 172.17.0.1 (docker0)
- SSH端口: 22
- Gateway端口: 8642

## 密钥信息

- 服务器私钥: ~/.ssh/id_ed25519
- 公钥标签: 150-center
- authorized_keys已配置
