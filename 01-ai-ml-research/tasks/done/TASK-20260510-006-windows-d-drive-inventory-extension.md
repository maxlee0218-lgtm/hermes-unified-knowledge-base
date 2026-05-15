---
task_id: TASK-20260510-006-windows-d-drive-inventory-extension
title: "补充：Windows D盘数仓与Agent相关文件摸排"
owner: "用户"
target_agent: "数据专家"
task_type: "DATA"
extension_for: "TASK-20260510-005-warehouse-rebuild-full-inventory"
objective: "补充读取 Windows 本地 D盘中与数仓、监控大屏、Agent Runtime、Hermes、OpenClaw、Dolphin、DataX、SQL、脚本、报告相关的文件和目录。"
allowed_actions:
  - 只读扫描Windows D盘
  - 读取目录结构
  - 读取 markdown/sql/json/yml/py/js 文件
  - 统计项目目录
  - 输出文件清单与风险
  - 更新 Wiki/GitHub
forbidden_actions:
  - 删除文件
  - 修改文件
  - 自动运行未知脚本
  - 自动启动服务
  - 自动修改数据库
  - 泄露密码或密钥
  - force push
acceptance_criteria:
  - 输出 Windows D盘核心目录树
  - 输出数仓相关项目清单
  - 输出监控大屏项目清单
  - 输出 SQL/脚本/配置统计
  - 输出高风险文件识别结果
  - 输出与 TASK-20260510-005 的关联关系
output_paths:
  - "Windows本地报告"
  - "/root/wiki/20-resources/windows-d-drive-inventory.md"
knowledge_update_required: true
timeout_minutes: 90
created_at: "2026-05-10T09:05:00+09:00"
---

# Windows D盘数仓与Agent相关文件摸排

用户追加要求：
在数仓重构前，必须补充读取 Windows 本地 D盘中的相关文件、项目、脚本和历史资料。

重点关注：
- data-warehouse
- AIWorker
- AIStack
- 监控大屏项目
- SQL脚本
- ADS/DWD/ODS相关文件
- 历史重构脚本
- Agent Runtime 文件
- Hermes/OpenClaw/PocketClaw 相关目录
- 历史报告与摸排文件

只读摸排，禁止自动执行未知脚本或启动服务。
