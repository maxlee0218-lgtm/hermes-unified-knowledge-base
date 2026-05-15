---
task_id: TASK-20260510-007-windows-c-drive-inventory-and-migration-plan
title: "Windows C盘部署物摸排与迁移到D盘方案"
owner: "用户"
target_agent: "数据专家"
task_type: "DATA"
extension_for: "TASK-20260510-006-windows-d-drive-inventory-extension"
objective: "只读盘点 Windows C盘中与 Agent、OpenClaw、Hermes、Python/Node、数仓、监控大屏、脚本、配置、服务相关的部署物，识别哪些应迁移到 D盘统一管理，并输出迁移方案。当前任务只做摸排和方案，不自动迁移。"
allowed_actions:
  - 只读扫描 Windows C盘相关目录
  - 读取目录结构与文件元信息
  - 识别已部署软件、项目、脚本、配置和服务引用
  - 识别 C盘中应迁移到 D盘的项目
  - 识别不能迁移或不建议迁移的系统组件
  - 输出 C盘资产清单
  - 输出 C盘到D盘迁移方案
  - 输出风险、依赖、回滚方案
  - 更新 Wiki/GitHub
forbidden_actions:
  - 删除文件
  - 移动文件
  - 修改文件
  - 自动迁移目录
  - 自动停止或启动服务
  - 自动修改环境变量
  - 自动修改注册表
  - 自动修改计划任务
  - 自动修改服务配置
  - 自动运行未知脚本
  - 自动修改数据库
  - 泄露密码、token、密钥、连接串
  - force push
acceptance_criteria:
  - 输出 Windows C盘核心部署物清单
  - 输出 C盘中 Agent/OpenClaw/Hermes/数仓/监控相关目录
  - 输出 C盘中 Python/Node/工具链相关路径
  - 输出服务、计划任务、快捷方式、环境变量对 C盘路径的引用风险
  - 输出可迁移到 D盘的候选清单
  - 输出不建议迁移的清单
  - 输出迁移优先级 P0/P1/P2
  - 输出迁移前备份方案
  - 输出迁移步骤草案
  - 输出回滚方案
  - 明确标注：本任务未执行迁移
  - 更新 Wiki/GitHub 并记录 commit id
output_paths:
  - "Windows本地报告"
  - "/root/wiki/20-resources/windows-c-drive-inventory-and-migration-plan.md"
knowledge_update_required: true
timeout_minutes: 90
created_at: "2026-05-10T09:20:00+09:00"
---

# Windows C盘部署物摸排与迁移到D盘方案

## 背景
用户追加要求：Windows C盘也要全部读一遍。当前 C盘上也部署了一些东西，如果可以，后续希望统一迁移到 D盘管理。

## 当前任务边界
本任务只做：
- 只读摸排；
- 清单整理；
- 风险识别；
- 迁移方案设计。

本任务不做：
- 实际移动文件；
- 实际修改服务；
- 实际修改环境变量；
- 实际修改注册表；
- 实际迁移部署。

## 重点摸排范围
请重点检查但不限于：

001 C盘项目与部署目录
- 用户目录下的开发项目
- 桌面/下载/文档中疑似项目
- Program Files / Program Files (x86) 中与 Agent 或开发工具有关的软件
- ProgramData 中相关配置
- Python/Node/npm/pnpm/yarn 相关路径
- OpenClaw / Hermes / Multica / PocketClaw 相关目录
- 数仓、数据分析、监控大屏相关目录

002 服务与启动项
- Windows 服务中是否引用 C盘路径
- 计划任务中是否引用 C盘路径
- 启动项中是否引用 C盘路径
- 快捷方式是否指向 C盘项目

003 配置与环境变量
- PATH 中 C盘路径
- 用户环境变量
- 系统环境变量
- .env/config/json/yaml 中的 C盘路径引用

004 安全与敏感信息
只识别风险，不输出敏感值。
如发现密码、token、密钥、连接串：
- 只记录“存在敏感信息”
- 不打印原文
- 给出迁移前脱敏建议

## 输出报告结构
报告标题：
《Windows C盘部署物摸排与迁移到D盘方案》

必须包含：

001 C盘摸排范围
- 扫描了哪些目录
- 跳过了哪些系统目录
- 为什么跳过

002 C盘部署物清单
- 路径
- 类型
- 归属项目
- 是否与当前 Agent/数仓/监控有关
- 是否建议迁移

003 C盘依赖引用清单
- 服务引用
- 计划任务引用
- 环境变量引用
- 快捷方式引用
- 配置文件引用

004 迁移候选清单
按 P0/P1/P2 分级：
- P0：强烈建议迁移到 D盘统一管理
- P1：可以迁移，但需测试
- P2：暂不迁移，只记录

005 不建议迁移清单
- 系统软件
- 安装器管理的软件
- 强依赖 C盘路径的软件
- 迁移风险高的组件

006 推荐 D盘统一目录结构
例如：
- D:\\AIStack\\
- D:\\AIWorker\\
- D:\\data-warehouse\\
- D:\\AIBackups\\

007 迁移前置条件
- 停止相关服务
- 备份目录
- 记录环境变量
- 记录计划任务
- 记录服务配置

008 迁移步骤草案
只写方案，不执行。

009 回滚方案
如何恢复 C盘原路径。

010 最终建议
是否建议迁移、先迁移哪些、哪些必须保留。

## 验收标准
用户和 ChatGPT 能基于本报告决定：
- 哪些 C盘内容该迁移；
- 迁移优先级；
- 迁移风险；
- 是否进入下一阶段“受控迁移任务”。
