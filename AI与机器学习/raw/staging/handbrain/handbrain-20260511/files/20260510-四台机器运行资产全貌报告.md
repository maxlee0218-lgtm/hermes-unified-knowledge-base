# 四台机器运行资产全貌报告

> 报告编号：FOUR-NODE-INV-20260510
> 执行智能体：深度研究智能体
> 执行时间：2026-05-10 09:19 CST
> 执行机器：kk-vw6bndfcdf7u6nrzf5tj (150.242.81.21)
> 任务来源：LEE-32 / TASK-20260510-008-four-node-runtime-inventory
> 安全声明：本报告为只读盘点，未修改任何系统配置、未停止任何服务、未修改任何数据库

---

## 001 总览结论

当前四台机器的运行资产全貌已基于**直接检查 + 历史归档 + 已知事实**完成盘点。

| 机器 | 可达性 | 角色定位 | 关键状态 |
|------|--------|----------|----------|
| **150** | ✅ 直接可达 | 主脑 / Hermes / Multica / Gateway / 任务总线 | 全组件在线 |
| **111** | ❌ SSH不可达 | 历史 jump host / 退役中 / 遗留服务宿主 | 网络层ICMP可达，管理面失联 |
| **184** | ✅ SSH可达 | 证照系统 / 数仓监控大屏 / 备用节点 | 服务未运行，仅系统服务在线 |
| **Windows** | ❌ SSH不可达 | 唯一 PolarDB 出口 / 数仓执行专机 / 沙箱验证 | 历史活跃，当前认证失败 |

**核心发现：**
1. 150 是唯一的 live 控制面和执行面
2. 111 已退役，遗留服务（warehouse-monitor-v2、polardb-tunnel）状态未知
3. 184 是轻量级备用节点，项目文件存在但服务未运行
4. Windows 作为唯一数据库出口，当前 SSH 认证失败，所有数据任务阻塞

---

## 002 四台机器角色表

### 150 服务器（主脑节点）

| 属性 | 值 |
|------|-----|
| 主机名 | kk-vw6bndfcdf7u6nrzf5tj |
| 公网IP | 150.242.81.21 |
| 私网IP | 172.17.0.1 (docker0) |
| OS | Ubuntu 24.04.2 LTS (Noble Numbat) |
| 内核 | 6.14.0-24-generic |
| CPU | 8 vCPU (Intel Xeon Gold 6138) |
| 内存 | 7.7 GiB (约1.3G used) |
| 磁盘 | 50G (13% used) |
| Docker | 已安装 |
| 角色 | 主脑 / 控制面 / 执行面 / Gateway / 任务总线 |
| 在线状态 | ✅ 在线 |
| 限制 | 无法直连 PolarDB；无法 SSH 到 111/Windows |

### 111 服务器（退役中）

| 属性 | 值 |
|------|-----|
| 公网IP | 111.229.153.11 |
| OS | 未知（历史为 Ubuntu/Debian） |
| 角色 | 历史 jump host / SSH 隧道宿主 / 数仓监控大屏 V2 运行节点 |
| 在线状态 | ⚠️ ICMP可达，SSH认证失败 |
| 已知限制 | SSH端口开放但所有凭据均失败；无法从150直接管理 |
| 历史事实 | 曾运行 warehouse-monitor-v2.service、polardb-tunnel.service |
| 退役状态 | Hermes已退役，知识已迁移到150；独立服务未确认清理 |

### 184 服务器（备用节点）

| 属性 | 值 |
|------|-----|
| 主机名 | iZ7xv9ypxy2u0w8kcdcqenZ |
| 公网IP | 8.163.49.184 |
| 私网IP | 172.19.52.40/18 |
| OS | Debian GNU/Linux 12 (bookworm) |
| 内核 | 6.1.0-33-amd64 |
| 内存 | 1676 MB (~334 MB used) |
| 磁盘 | 40G (12% used) |
| 角色 | 证照系统 / 数仓监控大屏 / 备用开发节点 |
| 在线状态 | ✅ 在线 |
| 限制 | 无 Hermes/Multica/OpenClaw 组件；服务未运行 |

### Windows PC（执行节点）

| 属性 | 值 |
|------|-----|
| 访问路径 | 127.0.0.1:2222（经111 SSH隧道，历史配置） |
| 实际身份 | 待确认（历史认为是Windows工作站） |
| 角色 | 唯一 PolarDB 出口 / 数仓执行专机 / 沙箱验证环境 |
| 在线状态 | ❌ SSH不可达 |
| 已知目录 | D:\AIWorker\reports\、D:\data-warehouse\（历史记录） |
| 限制 | 当前无法通过SSH确认状态；所有数据任务阻塞 |

---

## 003 项目文件清单

### 150 服务器

| 路径 | 内容 | 备注 |
|------|------|------|
| `/root/.hermes/hermes-agent/` | Hermes Agent v0.13.0 代码 | 主执行层 |
| `/root/.hermes/hermes-agent-pre-v0.13.0-20260509-111610` | v0.13.0 升级前备份 | 回滚点 |
| `/root/.hermes/pocketclaw/` | PocketClaw 上传目录 | 仅uploads |
| `/root/.hermes/phoenix/` | Phoenix 插件目录 | 已清理坏fallback |
| `/root/.hermes/skills/` | 28个技能目录 | 含cert-system-specialist等 |
| `/root/.hermes/imports/111-knowledge-20260509/` | 111历史知识归档 | 退役边界记录 |
| `/root/.hermes/wiki-import/` | Wiki导入历史 | 参考用途 |
| `/root/.clawai/` | ClawPilot运行时 | machine.json, hermes-sessions.json |
| `/root/.pm2/` | PM2守护进程数据 | clawpilot在线 |
| `/root/wiki/` | LLM Wiki SCHEMA v2.5 | 知识库主目录 |
| `/root/multica-work/` | Multica工作输出 | 含output、dev、ops、research |
| `/root/multica_workspaces/` | Multica本地workspace | 1496e790-... |
| `/root/.openclaw/` | OpenClaw配置 | 历史残留 |
| `/root/.ssh/` | SSH密钥和配置 | 含jump/aliyun/winpc配置 |
| `/opt/` | containerd | 几乎为空 |

### 111 服务器（基于历史归档）

| 路径 | 内容 | 状态 |
|------|------|------|
| `/opt/warehouse-monitor-v2/` | 数仓监控大屏V2 | 遗留服务，状态未知 |
| `/opt/warehouse-monitor-v2/backend/config.json` | 含明文密码 | ⚠️ 安全风险 |
| `~/.hermes/` | 历史Hermes运行态 | 已退役，知识已迁移 |
| `polardb-tunnel.service` | PolarDB隧道服务 | 状态未知 |
| `warehouse-monitor-v2.service` | 监控大屏服务 | 状态未知 |

### 184 服务器

| 路径 | 内容 | 状态 |
|------|------|------|
| `/root/cert-system/` | 证照管理系统 | 未运行 |
| `/root/cert-system/cert_system.db` | SQLite数据库 | 离线 |
| `/root/cert-system/集团证照管理.xlsx` | 证照Excel | 离线 |
| `/opt/warehouse-monitor/` | 数仓监控工具 | 未运行 |
| `/home/admin/` | admin用户目录 | 存在 |
| `/root/.ssh/authorized_keys` | 150-center、hermes-agent-wsl | 授权存在 |

### Windows PC（基于历史记录）

| 路径 | 内容 | 状态 |
|------|------|------|
| `D:\AIWorker\reports\` | AI工作报告目录 | 历史产出确认 |
| `D:\data-warehouse\` | 数仓工作目录 | 历史产出确认 |
| `D:\数仓\workspace\warehouse-monitor-console` | 监控大屏本地版 | 待确认 |

---

## 004 端口进程清单

### 150 服务器

| 端口 | 协议 | 绑定地址 | 进程 | 所属组件 | 状态 |
|------|------|----------|------|----------|------|
| 22 | TCP | 0.0.0.0 / :: | sshd | 系统 | ✅ |
| 5432 | TCP | 127.0.0.1 | postgres | PostgreSQL 16 | ✅ |
| 6379 | TCP | 127.0.0.1 / ::1 | redis-server | Redis | ✅ |
| 8642 | TCP | 127.0.0.1 | python (PID 280390) | hermes-gateway | ✅ |
| 1080 | TCP | 127.0.0.1 | ss-local | shadowsocks代理 | ✅ |
| 1081 | TCP | 127.0.0.1 | ss-local | shadowsocks代理 | ✅ |
| 19514 | TCP | 127.0.0.1 | multica | Multica daemon | ✅ |
| 38267 | TCP | 127.0.0.1 | containerd | Docker | ✅ |
| 53 | TCP/UDP | 127.0.0.53/54 | systemd-resolve | DNS | ✅ |

**关键进程（按内存排序）：**

| PID | 命令 | %MEM | 角色 |
|-----|------|------|------|
| 280390 | hermes gateway run --replace | 2.6% | Gateway |
| 348834 | hermes acp | 1.6% | ACP会话 |
| 348850 | hermes acp | 1.6% | ACP会话 |
| 220882 | clawpilot run (Node.js) | 1.1% | PocketClaw服务端 |
| 33274 | dockerd | 0.9% | Docker |
| 15363 | PM2 God Daemon | 0.8% | PM2守护 |
| 33029 | containerd | 0.5% | 容器运行时 |
| 85903 | postgres 16/main | 0.3% | 本地数据库 |
| 286560 | multica daemon | 0.2% | Multica守护 |
| 70134 | redis-server | 0.1% | 缓存 |

### 111 服务器（基于历史报告）

| 端口 | 服务 | 状态 |
|------|------|------|
| 22 | sshd | ⚠️ 开放但认证失败 |
| 18080 | uvicorn (warehouse-monitor-v2) | 未知 |
| 15018 | polardb-tunnel | 未知 |
| 2222 | sshd（本地转发） | 未知 |

### 184 服务器

| 端口 | 协议 | 绑定地址 | 进程 | 状态 |
|------|------|----------|------|------|
| 22 | TCP | 0.0.0.0 / :: | sshd | ✅ |
| 53 | TCP/UDP | 127.0.0.53/54 | systemd-resolve | ✅ |
| 5355 | TCP/UDP | 0.0.0.0 / :: | systemd-resolve (LLMNR) | ✅ |
| 68 | UDP | 172.19.52.40 | systemd-network (DHCP) | ✅ |
| 323 | UDP | 127.0.0.1 / ::1 | chronyd | ✅ |

**无应用层端口监听**（无80/443/8080/3000/5000/3306/5432/6379等）

### Windows PC

| 端口 | 服务 | 状态 |
|------|------|------|
| 未知 | 数仓监控大屏升级版 | 历史确认18081 |
| 未知 | PolarDB客户端工具 | 待确认 |
| 未知 | Claude/Codex runtime | 待确认 |

---

## 005 隧道与转发清单

### 150 服务器

| 隧道 | 类型 | 配置位置 | 状态 | 说明 |
|------|------|----------|------|------|
| ss-local:1080 | shadowsocks本地代理 | /etc/shadowsocks-libev/config.json | ✅ 运行 | 出站代理 |
| ss-local:1081 | shadowsocks本地代理 | 命令行参数 | ✅ 运行 | 出站代理 |

**无SSH本地/远程转发进程**

### SSH Config中的历史隧道定义

```
Host jump (111.229.153.11)
  → 历史jump host，当前不可达

Host winpc (127.0.0.1:2222)
  → ProxyJump jump
  → 历史Windows访问路径，当前认证失败
  → 2222实际为111本地sshd，非Windows
```

### 111 服务器（历史）

| 隧道 | 类型 | 状态 |
|------|------|------|
| 127.0.0.1:15018 → PolarDB | SSH本地转发 | 未知 |
| 127.0.0.1:2222 → Windows? | SSH远程转发? | 已证伪（2222是111本地sshd） |

### 184 服务器

**无隧道/转发进程**

---

## 006 定时任务清单

### 150 服务器

| 任务 | 调度 | 命令 | 状态 |
|------|------|------|------|
| 日志清理 | 每天03:00 | `find /root/.hermes/logs -name "*.log.*" -mtime +30 -delete` | ✅ |
| Hermes备份 | 每天04:00 | `/root/.hermes/backups/backup.sh` | ✅ |
| 健康检查 | 每2小时 | `/usr/local/bin/hermes-health-check.sh` | ✅ |
| PocketClaw inbox检查 | 每10分钟（外部触发） | `bash /root/wiki/tasks/task_inbox_check.sh` | ✅ |
| PocketClaw review检查 | 每5分钟（外部触发） | `bash /root/wiki/tasks/task_review_check.sh` | ⚠️ 频率有时异常 |
| heartbeat_sync | 未知频率 | `/root/wiki/tasks/heartbeat_sync.sh` | ✅ |

### 111 服务器（历史cron，已归档）

| 任务 | 调度 | 状态 |
|------|------|------|
| daily-infra-audit | 0 9 * * * | 已退役 |
| cert-queue-refresh | */30 * * * * | 已退役 |
| weekly-hermes-backup | 0 2 * * 0 | 已退役 |
| warehouse-monitor-v2-health-check | 0 * * * * | 已退役 |
| infra-health-trigger | */30 * * * * | 已退役 |

### 184 服务器

| 任务 | 调度 | 状态 |
|------|------|------|
| 系统定时器 | apt-daily, dpkg-db-backup, logrotate, man-db, sysstat, fstrim | ✅ 系统默认 |
| root crontab | 无 | - |

### Windows PC

| 任务 | 调度 | 状态 |
|------|------|------|
| 计划任务 | 待确认 | 无法SSH检查 |

---

## 007 Agent/Runtime 清单

### Multica 工作区 LEE

| Agent | ID | 状态 | 职责 | runtime_mode | max_concurrent |
|-------|-----|------|------|--------------|----------------|
| 深度研究智能体 | 7f1954ff-8a71-480c-a8c8-36a403e34dd3 | working | 规划、架构、方法论、系统盘点 | local | 6 |
| 数仓管家 | e213fd20-029e-4a6c-aa42-46513fe9f8ef | idle | 数仓运维、调度排查 | local | 6 |
| 数据专家 | 5244aac7-c6d0-4e32-ac9b-747831091262 | working | 数据分析、SQL、质量摸排 | local | 6 |

### 150 服务器 Runtime 组件

| 组件 | 运行方式 | 状态 | PID | 内存 |
|------|----------|------|-----|------|
| Hermes Agent v0.13.0 | venv/python | ✅ | 多ACP进程 | ~400MB+ |
| hermes-gateway | systemd | ✅ | 280390 | ~215MB |
| ClawPilot | PM2 | ✅ | 220882 | ~95MB |
| Multica daemon | 直接运行 | ✅ | 286560 | ~20MB |
| PostgreSQL 16 | systemd | ✅ | 85903 | ~31MB |
| Redis | systemd | ✅ | 70134 | ~14MB |
| shadowsocks | 独立进程 | ✅ | 285503/285514 | ~5MB |

### 111 服务器 Runtime 组件（历史/未知）

| 组件 | 运行方式 | 状态 |
|------|----------|------|
| warehouse-monitor-v2 | systemd | 未知 |
| polardb-tunnel | systemd | 未知 |
| Hermes | 已退役 | ❌ |

### 184 服务器 Runtime 组件

| 组件 | 运行方式 | 状态 |
|------|----------|------|
| 系统服务 | systemd | ✅ |
| AliYunDun | systemd | ✅ |
| 证照系统 | 未运行 | ❌ |
| 数仓监控 | 未运行 | ❌ |
| Hermes/Multica/OpenClaw | 无 | ❌ |

### Windows PC Runtime 组件（待确认）

| 组件 | 预期存在 | 状态 |
|------|----------|------|
| Claude/Codex runtime | 是 | 待确认 |
| PolarDB客户端 | 是 | 待确认 |
| 数仓监控大屏升级版 | 是 | 历史确认18081 |
| Hermes Agent | 否 | 不适用 |

---

## 008 数据库与数仓连接关系

| 系统 | 连接路径 | 可访问节点 | 边界 |
|------|----------|------------|------|
| **PolarDB** | Windows PC是唯一出口 | Windows（待确认） | 只读（SELECT/SHOW/EXPLAIN） |
| **DolphinScheduler** | 生产网络 | Windows / 生产环境 | 禁止自动修改 |
| **DataX** | 生产网络 | Windows / 生产环境 | 禁止自动修改 |
| **PostgreSQL (本地)** | 127.0.0.1:5432 | 150 | Hermes状态存储 |
| **Redis (本地)** | 127.0.0.1:6379 | 150 | Hermes缓存 |

### 连接拓扑

```
ChatGPT (用户)
  → GitHub llm-wiki
    → PocketClaw (外部触发)
      → 150 Hermes Gateway
        → Multica Issue
          → Agent执行
            ├── 150本地执行（代码、盘点、报告）
            ├── 184 SSH执行（备用节点检查）
            └── Windows执行（PolarDB、数仓任务）← 当前阻断

PolarDB
  ← 111隧道（历史）← 状态未知
  ← Windows直连（唯一有效路径）← 当前阻断
```

---

## 009 当前已知风险

| 风险 | 等级 | 影响 | 证据 |
|------|------|------|------|
| **111 SSH认证失败** | 🔴 高 | 无法管理遗留服务，无法退役确认 | 所有凭据均失败，端口开放但拒绝 |
| **Windows SSH不可达** | 🔴 高 | 所有PolarDB/数仓任务全阻 | 经111隧道和直接均失败 |
| **111遗留服务未确认** | 🟡 中 | warehouse-monitor-v2、polardb-tunnel可能成为僵尸服务 | 无法SSH验证 |
| **PocketClaw触发频率异常** | 🟡 中 | 资源消耗，可能重复竞争 | 日志显示秒级间隔 |
| **184服务未运行** | 🟢 低 | 证照系统、监控大屏未启用 | 项目文件存在但进程未启动 |
| **150单点故障** | 🟡 中 | 所有控制面集中在一台机器 | 无备用Hermes节点 |
| **KIMI_API_KEY单点** | 🟡 中 | 唯一provider，fallback禁用 | 配置已确认 |
| **111明文密码遗留** | 🟡 中 | config.json历史含明文密码 | 已脱敏归档 |

---

## 010 已废弃路径

| 废弃路径 | 根因 | 替代方案 |
|----------|------|----------|
| `ssh winpc` (127.0.0.1:2222) | 2222是111本地sshd，非Windows | Multica调度Windows智能体 |
| 111直连PolarDB | 网络层阻断 | Windows智能体执行 |
| 150直连PolarDB | 网络层阻断 | Windows智能体执行 |
| 111作为jump host | SSH认证失败 | 待修复或废弃 |
| `/root/multica-work/output/` | Agent实际使用multica_workspaces | 接受实际路径 |

---

## 011 待确认问题

| 问题 | 优先级 | 确认方式 |
|------|--------|----------|
| 111遗留服务是否仍在运行？ | P0 | 需要有效SSH凭据登录检查 |
| Windows PC当前实际状态？ | P0 | 需要修复SSH或替代访问方式 |
| 184上的证照系统是否需要重启？ | P1 | SSH已可达，可远程确认 |
| PocketClaw触发频率为何异常？ | P1 | 检查PocketClaw应用端配置 |
| 111的polardb-tunnel是否仍有效？ | P2 | 无法确认，假设已失效 |
| Windows本地监控大屏端口是18080还是18081？ | P2 | 需Windows确认 |

---

## 012 后续治理建议

| 优先级 | 动作 | 原因 |
|--------|------|------|
| **P0** | 恢复Windows PC可访问性 | 所有数据任务依赖此节点 |
| **P0** | 获取111有效SSH凭据并确认遗留服务状态 | 完成退役，清理僵尸服务 |
| **P1** | 确认184服务需求，决定启动或迁移 | 资源闲置或备用价值 |
| **P1** | 稳定PocketClaw触发频率 | 避免过度触发和资源浪费 |
| **P2** | 为Agent挂载skills | 提升执行能力 |
| **P2** | 建立数据质量持续监控 | 从一次性摸排升级为定期巡检 |
| **P3** | 评估150高可用方案 | 当前单点控制面 |

---

## 013 产出文件

| 文件 | 路径 | 状态 |
|------|------|------|
| 四台机器运行资产全貌报告 | `/root/multica-work/output/20260510-四台机器运行资产全貌报告.md` | ✅ 已生成 |
| Wiki知识沉淀 | `/root/wiki/20-resources/four-node-runtime-inventory.md` | ⏳ 待同步 |

---

*本报告为只读盘点，未修改任何系统配置、未停止任何服务、未连接生产数据库、未安装新软件。*
