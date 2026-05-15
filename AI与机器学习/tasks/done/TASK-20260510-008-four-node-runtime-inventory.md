---
task_id: TASK-20260510-008-four-node-runtime-inventory
title: "四台机器全局运行资产摸排：项目文件/端口/进程/隧道"
owner: "用户"
target_agent: "深度研究智能体"
task_type: "KNOWLEDGE"
knowledge: true
objective: "对当前四台机器：1500、111、184、Windows 的项目文件、运行服务、端口、进程、隧道、定时任务、Agent组件和网络关系进行全量只读梳理，输出统一运行拓扑和资产清单。"
allowed_actions:
  - 只读检查四台机器的已知资料
  - 读取 /root/wiki 和 /root/multica-work/output
  - 读取已有 Windows 报告
  - 检查 GitHub llm-wiki 中相关任务和知识文件
  - 检查 Multica 任务状态
  - 汇总各机器项目目录、服务、端口、进程、隧道、定时任务
  - 输出统一拓扑图文本和资产清单
  - 输出风险和整改建议
  - 更新 LLM Wiki/GitHub
forbidden_actions:
  - 停止进程
  - 启动服务
  - 重启服务
  - 杀进程
  - 修改端口
  - 修改防火墙
  - 修改隧道
  - 修改 SSH 配置
  - 修改生产数据库
  - 修改 DolphinScheduler
  - 修改 DataX
  - 自动迁移文件
  - 删除文件
  - 修改系统配置
  - 泄露密码、token、密钥、连接串
  - force push
acceptance_criteria:
  - 输出四台机器清单：1500、111、184、Windows
  - 输出每台机器的角色定位
  - 输出每台机器的项目文件目录清单
  - 输出每台机器的关键进程清单
  - 输出每台机器的监听端口清单
  - 输出每台机器的隧道/转发/代理清单
  - 输出每台机器的定时任务/计划任务清单
  - 输出每台机器的 Agent/Hermes/OpenClaw/Multica/PocketClaw 组件清单
  - 输出机器之间的调用关系与数据流
  - 输出未知项和待补充项
  - 输出风险清单和下一步治理建议
  - 不执行任何变更动作
  - 更新 Wiki/GitHub 并记录 commit id
output_paths:
  - "/root/multica-work/output/20260510-四台机器运行资产全貌报告.md"
  - "/root/wiki/20-resources/four-node-runtime-inventory.md"
knowledge_update_required: true
timeout_minutes: 90
created_at: "2026-05-10T09:35:00+09:00"
---

# 四台机器全局运行资产摸排

## 背景
用户明确当前只有四台机器需要统一梳理：
- 1500
- 111
- 184
- Windows

需要把这些机器上的项目文件、端口、进程、隧道、定时任务、Agent组件、运行关系全部梳理清楚。

## 目标
建立一份“运行资产全貌基线”，用于后续统一治理、迁移、重构和排障。

## 必须覆盖范围

### 001 机器清单
对每台机器输出：
- 名称/编号
- IP或访问方式（如已知）
- 操作系统
- 主要职责
- 是否为控制面/执行面/备份/恢复/Windows Worker
- 当前是否在线
- 已知限制

### 002 项目文件
对每台机器输出：
- 关键项目目录
- Agent目录
- Wiki目录
- 备份目录
- 脚本目录
- 数仓/监控/大屏相关目录
- 历史遗留目录
- 需要保留/归档/迁移的目录

### 003 端口与进程
对每台机器输出：
- 当前监听端口
- 端口对应进程
- 进程启动命令
- 是否属于 OpenClaw/Hermes/Multica/PocketClaw/监控大屏/数据库隧道
- 是否有未知监听端口
- 是否有重复或冲突端口

### 004 隧道/转发/代理
必须梳理：
- SSH 隧道
- 本地端口转发
- 反向代理
- 127.0.0.1:2222 这类历史误判路径
- Windows 与 111/1500/184 的连接方式
- 是否存在长期隧道
- 是否存在临时隧道
- 哪些路径已废弃

### 005 定时任务
必须梳理：
- PocketClaw 10分钟 inbox loop
- PocketClaw 5分钟 review loop
- heartbeat sync
- Linux cron/systemd timer
- Windows 计划任务
- launchd 或其他常驻机制（如有）

### 006 Agent / Runtime
必须梳理：
- OpenClaw
- Hermes
- Multica
- PocketClaw
- 数据专家
- 数仓管家
- 深度研究智能体
- Windows Worker
- 当前注册状态
- 当前运行状态
- 当前责任边界

### 007 数据与业务系统连接
必须梳理：
- PolarDB 连接路径
- DolphinScheduler 访问路径
- DataX 访问路径
- Windows 作为唯一 PolarDB 执行出口的事实
- 111/1500/184 是否能直连或不能直连
- 数据库只读边界

### 008 网络关系图
输出文本拓扑，例如：

```text
ChatGPT
  -> GitHub llm-wiki
  -> PocketClaw on 1500
  -> Multica
  -> Agent
  -> Windows / 111 / 184
```

并标注：
- 控制流
- 数据流
- 文件流
- 任务流
- 禁止路径

## 输出报告结构

报告标题：
《四台机器运行资产全貌报告》

必须包含：

001 总览结论
002 四台机器角色表
003 项目文件清单
004 端口进程清单
005 隧道与转发清单
006 定时任务清单
007 Agent/Runtime清单
008 数据库与数仓连接关系
009 当前已知风险
010 已废弃路径
011 待确认问题
012 后续治理建议

## 严格边界
本任务只读盘点，不允许任何变更动作。
不允许停服务、不允许重启、不允许杀进程、不允许改端口、不允许改防火墙、不允许改隧道。

## 重要说明
如果无法直接读取某台机器，请基于已有 Wiki、报告、Multica 记录先输出“已知事实”和“待确认项”，不要编造。
