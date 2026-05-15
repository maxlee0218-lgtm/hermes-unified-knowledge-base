---
title: 系统运行态全貌
created: 2026-05-10
updated: 2026-05-10
stage: stable
type: runbook
tags: [系统盘点, 运行态, 硬件, 软件, Agent, 风险]
status: active
sources: [20260510-系统全貌盘点报告]
commit: TBD
---

# 系统运行态全貌

> 全局系统全貌盘点报告的知识沉淀版本
> 基于 LEE-26 / TASK-20260510-002 执行结果

---

## 一、硬件与节点

| 节点 | IP / 标识 | 状态 | 角色 |
|------|-----------|------|------|
| **150 服务器** | 150.242.81.21 | ✅ 在线 | 主脑 / Hermes / Multica / Gateway |
| **111 服务器** | 111.229.153.11 | ⚠️ 网络可达，管理不可达 | 历史 jump host / 退役中 |
| **Windows PC** | 127.0.0.1:2222 (经111隧道) | ⚠️ 历史活跃，当前不可SSH | 唯一 PolarDB 出口 / 数仓执行专机 |
| **PocketClaw** | 与150同机 | ✅ 在线 | 外部调度器 / 任务触发器 |

### 150 服务器详情
- OS: Ubuntu 24.04.2 LTS
- CPU: 8 vCPU (Intel Xeon Gold 6138)
- 内存: 7.7 GiB (1.3G used)
- 磁盘: 50G (13% used)
- Docker: 已安装

---

## 二、软件与 Runtime

| 软件 | 状态 | 角色 |
|------|------|------|
| Hermes Agent v0.13.0 | ✅ 运行 | 主执行层 |
| hermes-gateway | ✅ systemd active | 消息网关 |
| ClawPilot | ✅ PM2 online | PocketClaw 服务端 |
| Multica | ✅ CLI 可用 | 任务总线 |
| PocketClaw | ✅ 定时触发 | 任务调度器 |
| GitHub llm-wiki | ✅ 同步正常 | 任务总线 / 知识归档 |
| LLM Wiki SCHEMA v2.5 | ✅ 活跃 | 知识库 |

### Hermes 配置要点
- Provider: `kimi-coding` → `kimi-k2.6`
- Fallback: **已禁用**
- 唯一 key: `KIMI_API_KEY`

---

## 三、Agent

| Agent | 状态 | 职责 |
|-------|------|------|
| 深度研究智能体 | working | 规划、架构、方法论、系统盘点 |
| 数仓管家 | idle | 数仓运维、调度排查 |
| 数据专家 | idle | 数据分析、SQL、质量摸排 |

- 全部 3 个 Agent 已注册于 Multica 工作区 LEE
- max_concurrent_tasks: 6
- 当前无 skills 挂载

---

## 四、当前任务状态

| 状态 | 数量 | 关键 Issue |
|------|------|------------|
| in_progress | 2 | LEE-26 (本任务), LEE-25 (重复) |
| in_review | 1 | LEE-25 |
| blocked | 1 | LEE-23 (Agent协同加固) |
| done | 20+ | LEE-24, 22, 21, 19, 18~1 |
| cancelled | 3 | LEE-20, 8, 7 |

---

## 五、数据系统边界

| 系统 | 连接路径 | 边界 |
|------|----------|------|
| PolarDB | Windows PC 是唯一出口 | 只读 |
| DolphinScheduler | 经 Windows 或生产网络 | 禁止自动修改 |
| DataX | 经 Windows 或生产网络 | 禁止自动修改 |
| ODS/DWD/ADS | 经 Windows 智能体 | 数仓分层 |

---

## 六、协同链路

```
ChatGPT → GitHub → PocketClaw → 150 → Multica → Agent → REVIEW/DONE → Wiki/GitHub
```

- 全链路已打通 ✅
- Agent → Windows 当前阻断 ⚠️

---

## 七、风险与阻断

| 风险 | 等级 |
|------|------|
| 111 SSH 认证失败 | 🔴 高 |
| Windows PC SSH 不可达 | 🔴 高 |
| LEE-23 blocked 长期未解 | 🟡 中 |
| PocketClaw 触发频率异常 | 🟡 中 |
| 111 遗留服务未确认 | 🟡 中 |

### 单点故障
- Windows PC: 唯一 PolarDB 出口
- PocketClaw: 唯一任务触发器
- KIMI_API_KEY: 单一 provider

---

## 八、阶段判断

**阶段**: 基础设施结束，有限正式运行

### 已成熟 ✅
- Hermes / Gateway / ClawPilot 稳定
- Multica 任务总线正常
- GitHub → Agent 全链路打通
- 安全边界生效
- 知识沉淀三层闭环

### 实验态 ⚠️
- Agent 协同自动化 (有阻塞)
- PocketClaw 定时稳定性
- Windows 节点连接可靠性
- 111 退役完成度
- 数据质量持续监控

---

## 九、下一阶段建议

| 优先级 | 动作 |
|--------|------|
| P0 | 恢复 Windows PC 可访问性 |
| P0 | 解决 LEE-23 blocked |
| P1 | 完成 111 退役确认 |
| P1 | 稳定 PocketClaw 触发频率 |
| P2 | 为 Agent 挂载 skills |
| P2 | 建立数据质量持续监控 |

---

*本文件为知识沉淀，只读盘点，未修改任何系统。*
