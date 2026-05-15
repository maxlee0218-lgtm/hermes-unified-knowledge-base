---
title: "Windows C盘部署物摸排与迁移到D盘方案"
description: "只读盘点 Windows C盘中与 Agent、OpenClaw、Hermes、Python/Node、数仓、监控大屏、脚本、配置、服务相关的部署物，识别迁移候选、依赖风险和回滚方案。"
author: "数据专家 (Kimi Claw)"
date: "2026-05-11"
version: "v1.2"
status: "in_progress"
task_id: "TASK-20260510-007-windows-c-drive-inventory-and-migration-plan"
issue_id: "LEE-58"
---

# Windows C盘部署物摸排与迁移到D盘方案

> **执行机器**: kk-vw6bndfcdf7u6nrzf5tj (Linux Ubuntu 24.04.2 LTS)  
> **执行用户**: root  
> **执行智能体**: 数据专家 (Kimi Claw Windows Worker)  
> **执行时间**: 2026-05-11 07:55 UTC  
> **任务名称**: Windows C盘部署物摸排与迁移到D盘方案  
> **任务来源**: Multica issue LEE-58 (4facd56d-3b6e-4dfe-933c-054629ce7f64)  
> **报告版本**: v1.2 (基于 v1.1 实测数据更新)

---

## 重要声明

1. **本任务严格只读**：扫描期间未移动文件、未删除文件、未修改服务、未修改计划任务、未改环境变量、未输出密钥或连接串。
2. **本任务未执行迁移**：只输出方案，不自动执行任何迁移操作。
3. **执行环境限制**：当前执行节点为 Linux 云主机，无法直接访问 Windows C 盘物理文件系统。本报告基于此前在 Windows 节点（`winpc` via `jump`）上完成的实测扫描数据（v1.1）进行整理、更新和补充。因 SSH jump 主机（111.229.153.11）当前不可达，本次无法执行增量扫描。
4. **数据时效性**：实测数据收集于 2026-05-10，如 Windows 节点已有变更，建议重新执行扫描。

---

## 001 结论

当前 C 盘部署物不是单一目录问题，而是两个用户 profile 与 D 盘工作区混用：

| 判断 | 结论 |
|------|------|
| 主要运行时 profile | `C:\Users\hermes` |
| 主要人工登录 profile | `C:\Users\39169` |
| 当前工作区主目录 | `D:\AIWorker`、`D:\data-warehouse` |
| 最高风险 | 快捷方式、批处理、计划任务跨 profile 引用，部分目标路径已不存在 |
| 迁移建议 | 不做一次性搬家，先做 D 盘标准目录和启动入口统一，再分批迁移状态目录 |

优先处理三类问题：

1. **修复跨 profile 启动入口**：Kimi、智灵云、Multica 兼容模式、Multica daemon 启动脚本。
2. **迁移或固化 Agent 状态目录**：`.cc-connect`、`.clawai`、`.codex`、`.claude`、`.kimi`、`.multica`、`.openclaw`、`.hermes`。
3. **清理失效计划任务**：`warehouse-monitor-console`、`dolphinscheduler-standalone-test` 相关任务引用的脚本当前缺失。

---

## 002 扫描范围

### 已扫描目录

- `C:\` 根目录一层。
- `C:\Users\39169`、`C:\Users\hermes` 的关键隐藏目录、桌面、开始菜单、AppData 本地程序目录。
- `C:\Program Files`、`C:\Program Files (x86)`、`C:\ProgramData` 中与 Agent、开发工具、远程控制、Python/Node、Java、WSL 相关目录。
- Windows 服务、计划任务、用户环境变量、系统环境变量。
- 桌面和开始菜单快捷方式目标路径。

### 跳过或仅做一层摘要的目录

| 目录 | 跳过原因 |
|------|----------|
| `C:\Windows` | 系统核心目录，不建议迁移 |
| `C:\Program Files\WindowsApps` | 受 UWP 保护，无法手工迁移 |
| `System Volume Information` | 系统还原数据，不可访问 |
| `$Recycle.Bin` | 回收站，无需迁移 |
| `node_modules` 深层 | 可重建，体积大，只记录归属 |
| Python `site-packages` 深层 | 可重建，只记录归属 |
| 缓存/临时目录深层 | 可重建，不做逐文件清单 |
| `.env`、token、key、连接串 | 只记录"存在敏感配置"，不输出原文 |

---

## 003 C盘部署物清单

| 路径 | 类型 | 归属 | 与 Agent/数仓/监控关系 | 是否建议迁移 |
|------|------|------|------------------------|--------------|
| `C:\Users\39169\.hermes` | Hermes 运行数据和 Python venv | Hermes | 有 `config.yaml`、`.env`、`venv`、logs、sessions | **P0 迁移或固化到 D 盘** |
| `C:\Users\39169\.clawai` | ClawPilot 配置 | ClawPilot | 有 runtime/helper 配置 | **P1 迁移** |
| `C:\Users\39169\.multica\bin` | Multica CLI 二进制 | Multica | `multica.exe` 当前可用命令来源 | **P0 纳入统一工具目录** |
| `C:\Users\39169\.multica` | Multica 配置和旧 daemon 日志 | Multica | 与 `hermes` profile 的 `.multica` 并存 | **P0 统一 profile** |
| `C:\Users\39169\.openclaw` | OpenClaw 配置和 workspace | OpenClaw | 与 agent 运行有关 | **P1 迁移** |
| `C:\Users\39169\.dbt` | dbt 配置 | 数仓 | 与 `D:\data-warehouse` 快捷方式有关 | **P1 备份后迁移** |
| `C:\Users\39169\.kimi` | Kimi 本地配置 | Kimi | 登录态/会话类数据 | **P1 备份，迁移需重新验证登录** |
| `C:\Users\39169\mainbrain` | 主脑/守护脚本 | Mainbrain | 计划任务引用 `windows_guardian_host.ps1` | **P0 保留或迁移后改计划任务** |
| `C:\Users\39169\AppData\Local\Programs\kimi-desktop` | Kimi 桌面程序 | Kimi | `Kimi.exe` 实际存在于此 profile | **不建议直接搬，重装或修快捷方式** |
| `C:\Users\39169\AppData\Local\智灵云2026` | 智灵云本地程序 | 代理/网络工具 | `zlincloud.exe` 实际存在于此 profile | **不建议直接搬，重装或修快捷方式** |
| `C:\Users\hermes\.cc-connect` | Claude/Codex 连接守护 | cc-connect | 计划任务正在调用，含 logs、sessions、config | **P0 迁移或明确保留** |
| `C:\Users\hermes\.clawai` | ClawPilot relay | ClawPilot | `clawpilot-relay` 计划任务正在运行 | **P0 迁移或明确保留** |
| `C:\Users\hermes\.codex` | Codex 状态和会话 | Codex | 当前 Codex 状态数据库、技能、会话 | **P0 备份，迁移需停进程** |
| `C:\Users\hermes\.claude` | Claude Code 状态 | Claude | 会话、项目、skills | **P1 备份后迁移** |
| `C:\Users\hermes\.kimi` | Kimi CLI 状态 | Kimi | credentials、sessions、logs | **P1 备份，迁移需重新验证登录** |
| `C:\Users\hermes\.multica` | Multica daemon 状态 | Multica | 有 `daemon.log`、`daemon.pid`，无 `bin` | **P0 和 `39169\.multica\bin` 统一** |
| `C:\Users\hermes\.openclaw` | OpenClaw agents/plugins/tasks | OpenClaw | 当前运行配置 | **P1 迁移** |
| `C:\Users\hermes\AppData\Local\Programs\@multicadesktop` | Multica 桌面程序 | Multica | `Multica.exe` 实际存在于此 profile | **不直接搬，重装或修入口** |
| `C:\Users\hermes\AppData\Roaming\npm` | npm 全局命令 | Claude/ClawPilot | `claude.cmd`、`clawpilot.cmd` 实际存在 | **P0 纳入工具链策略** |
| `C:\Users\hermes\multica_workspaces` | Multica workspace | Multica | 工作区数据 | **P1 迁移或清理** |
| `C:\Users\hermes\pocketclaw-work` | PocketClaw 工作区 | PocketClaw | 可能为旧工作目录 | **P1 确认后迁移/归档** |
| `C:\Program Files\ToDesk` | 远控软件 | ToDesk | 服务正在运行 | **不建议手工搬，按安装器迁移** |
| `C:\Program Files\Wukong` | Wukong 程序 | Wukong | 含 bin/resources/skills | **不建议手工搬，按安装器迁移** |
| `C:\Program Files\nodejs` | Node.js | 工具链 | 系统级 Node | **不建议搬，重装到目标路径** |
| `C:\Program Files\Git` | Git for Windows | 工具链 | 含 `root\wiki`、`root\multica-work` 历史路径 | **Git 本体不搬，历史路径需清理** |
| `C:\Program Files\Eclipse Adoptium` | JDK 17 | Java | `JAVA_HOME` 指向这里 | **不建议搬，重装或保留** |
| `C:\Program Files\WSL` | WSL | 系统组件 | WSL runtime | **不迁移** |
| `C:\root\wiki`、`C:\root\multica-work` | 类 Linux 根目录残留 | Wiki/Multica | 与 Git for Windows/MSYS 路径有关 | **P1 确认后归档** |
| `C:\home\wukong\.hermes` | Wukong profile 下 Hermes 配置 | Wukong/Hermes | 旧或独立配置 | **P2 只备份不优先迁移** |
| `C:\tmp\dolphinscheduler` | 临时 Dolphin 执行目录 | DolphinScheduler 测试 | exec/process/test 目录 | **P2 清理前先确认** |
| `C:\tmp\multica-gateway-test` | Gateway 测试目录 | Multica gateway | done/failed/pending/running | **P2 测试归档** |
| `C:\tmp\openclaw` | OpenClaw 临时任务 | OpenClaw | auto-memory 相关 | **P2 测试归档** |
| `C:\apache-zookeeper-3.8.3-bin` | Zookeeper | 测试/中间件 | 可能与 Dolphin 独立测试相关 | **P1 确认用途** |
| `C:\nssm` | Windows service helper | 服务包装 | 可能用于注册本地服务 | **P1 归入工具目录** |
| `C:\inetpub` | IIS 目录 | Web/系统 | 可能为空或历史配置 | **P2 只记录** |

---

## 004 Python/Node/工具链路径

| 类型 | 路径 | 判断 |
|------|------|------|
| Java | `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot` | `JAVA_HOME` 指向此处，保留或重装 |
| Node.js | `C:\Program Files\nodejs` | 系统级工具，不直接搬 |
| npm 全局命令 | `C:\Users\hermes\AppData\Roaming\npm` | Claude/ClawPilot 命令入口，P0 需标准化 |
| Python | `C:\Users\39169\AppData\Local\Programs\Python` | 用户级 Python，迁移建议改为 D 盘工具链或重装 |
| D 盘工具链 | `D:\AIWorker\agent-tools\Python312`、`D:\AIWorker\agent-tools\npm` | 已有统一工具链，应作为目标方向 |
| dbt | `D:\data-warehouse\01-dbt-duckdb` | 已在 D 盘，C 盘只保留快捷方式 |

---

## 005 服务、计划任务与启动项引用

### Windows 服务

| 服务 | 状态 | 路径 | 建议 |
|------|------|------|------|
| `ToDesk_Service` | Running / Auto | `C:\Program Files\ToDesk\ToDesk.exe --runservice` | 不手工迁移，需通过安装器处理 |
| `sshd` | Running / Auto | Windows OpenSSH | 保留 |
| `WSLService` | Running / Auto | WSL | 保留 |

> **未发现名为 Hermes、Multica、OpenClaw、ClawPilot 的 Windows Service。**

### 关键计划任务

| 任务 | 状态 | 当前动作 | 判断 |
|------|------|----------|------|
| `cc-connect-daemon` | Running | `C:\Users\hermes\.cc-connect\start-cc-connect.ps1` | **P0 运行时入口** |
| `clawpilot-relay` | Running | `C:\Users\hermes\.clawai\start-clawpilot-relay.ps1` | **P0 运行时入口** |
| `ClawPilotCcConnect` | Ready | `C:\Users\hermes\.cc-connect\start-cc-connect.cmd` | **P1 同类备用入口** |
| `ClawPilotRelay` | Ready | `C:\Users\hermes\.clawai\start-clawpilot.cmd` | **P1 同类备用入口** |
| `codex-stuck-watchdog` | Ready | `C:\Users\hermes\.cc-connect\codex-stuck-watchdog.ps1` | **P1 watchdog** |
| `MainbrainWindowsGuardianHost` | Ready | `C:\Users\39169\mainbrain\guardians\windows_guardian_host.ps1` | **P0 主脑守护入口，目标存在** |
| `MulticaGitGateway` | Ready | `D:\AIWorker\llm-wiki\scripts\run-multica-git-gateway.ps1` | **已在 D 盘** |
| `MulticaGitGatewaySystem` | Ready | `D:\AIWorker\scripts\run-multica-git-gateway-system.ps1` | **已在 D 盘** |
| `DolphinStandaloneEnsure` | Disabled | `C:\Users\39169\Documents\dolphinscheduler-standalone-test\ensure_dolphinscheduler_standalone_running.ps1` | **目标文件缺失** |
| `DolphinStandaloneTestEnvLoop` | Disabled | `C:\Users\39169\Documents\dolphinscheduler-standalone-test\run_dolphinscheduler_standalone_loop.ps1` | **目标文件缺失** |
| `DolphinUiProxyCodex` | Disabled | `C:\Users\39169\Documents\dolphinscheduler-standalone-test\run_dolphinscheduler_ui_proxy.cmd` | **目标文件缺失** |
| `PolarDB-ReverseTunnel` | Disabled | `C:\Users\39169\AppData\Local\Temp\polardb-tunnel.ps1` | **临时目录引用，高风险** |
| `WarehouseMonitorConsole` | Ready | `C:\Users\39169\Documents\warehouse-monitor-console\start_warehouse_monitor_console.cmd` | **目标目录/脚本缺失** |
| `WarehouseMonitorConsoleCodex` | Disabled | `C:\Users\39169\Documents\warehouse-monitor-console\run_warehouse_monitor_console.cmd` | **目标目录/脚本缺失** |
| `WarehouseMonitorSnapshotRefresh` | Disabled | `C:\Users\39169\Documents\warehouse-monitor-console\refresh_warehouse_monitor_snapshot.cmd` | **目标目录/脚本缺失** |

---

## 006 快捷方式和脚本风险

| 入口 | 当前目标 | 存在性 | 处理建议 |
|------|----------|--------|----------|
| `C:\Users\39169\Desktop\Kimi.lnk` | `C:\Users\hermes\AppData\Local\Programs\kimi-desktop\Kimi.exe` | **不存在** | 改到 `C:\Users\39169\AppData\Local\Programs\kimi-desktop\Kimi.exe` 或重装 |
| `C:\Users\39169\Desktop\Kimi-修复版.lnk` | 同上，带 GPU 参数 | **不存在** | 同上 |
| `C:\Users\39169\Desktop\智灵云2026.lnk` | `C:\Users\hermes\AppData\Local\智灵云2026\zlincloud.exe` | **不存在** | 改到 `C:\Users\39169\AppData\Local\智灵云2026\zlincloud.exe` |
| `C:\Users\39169\Desktop\Multica.lnk` | `C:\Users\hermes\AppData\Local\Programs\@multicadesktop\Multica.exe` | **存在** | 可保留，但应减少跨 profile 依赖 |
| `C:\Users\hermes\Desktop\Multica.lnk` | `C:\Users\hermes\AppData\Local\Programs\@multicadesktop\Multica.exe` | **存在** | 可保留 |
| `C:\Users\hermes\Desktop\Multica-兼容模式.bat` | `C:\Users\39169\AppData\Local\Programs\@multicadesktop\Multica.exe` | **不存在** | 改到 `hermes` profile 的 Multica |
| `C:\Users\hermes\Desktop\启动 Multica Daemon.bat` | `C:\Users\39169\.multica\bin\multica.exe daemon start`，并设置 `MULTICA_CLAUDE_PATH` 到 `C:\Users\hermes\AppData\Roaming\npm\claude.cmd` | 二进制存在，但 profile 混用 | **P0 标准化** |
| `C:\Users\hermes\Desktop\数仓-dbt.lnk` | `powershell.exe -File D:\data-warehouse\shell\start-dbt.ps1` | D 盘目标 | **保留** |
| `WarehouseMonitorConsole.lnk` | `C:\Users\hermes\Desktop` | 指向目录，不是脚本 | **需重建** |

---

## 007 迁移候选清单（P0/P1/P2 分级）

### P0：强烈建议迁移到 D 盘统一管理

| 对象 | 目标建议 | 原因 |
|------|----------|------|
| `C:\Users\hermes\.cc-connect` | `D:\AIStack\runtime\cc-connect` | 当前运行中的连接守护 |
| `C:\Users\hermes\.clawai` | `D:\AIStack\runtime\clawai` | 当前运行中的 relay |
| `C:\Users\hermes\.codex` | `D:\AIStack\runtime\codex` | Codex 状态库和会话 |
| `C:\Users\hermes\.multica` + `C:\Users\39169\.multica` | `D:\AIStack\runtime\multica` | 二进制和 daemon 状态分散在两 profile |
| `C:\Users\39169\.hermes` | `D:\AIStack\runtime\hermes-legacy` 或归档 | 旧 Hermes 运行数据，含 venv/config/logs |
| `C:\Users\39169\mainbrain` | `D:\AIStack\mainbrain` | 计划任务引用主脑守护脚本 |
| 计划任务入口 | 统一改到 D 盘脚本 | 降低 profile 路径漂移 |
| 桌面/开始菜单快捷方式 | 统一改到有效路径 | 当前多条坏链 |

### P1：可以迁移，但需测试

| 对象 | 目标建议 | 原因 |
|------|----------|------|
| `C:\Users\hermes\.claude`、`.kimi`、`.openclaw` | `D:\AIStack\runtime\...` | 状态和会话目录，需验证登录态 |
| `C:\Users\39169\.clawai`、`.openclaw`、`.dbt`、`.kimi` | `D:\AIStack\profiles\39169\...` | 辅助配置 |
| `C:\root\wiki`、`C:\root\multica-work` | 归档到 `D:\AIBackups\c-root-*` | 疑似 Git/MSYS 历史路径 |
| `C:\Users\39169\Documents\stock-dolphin-refactor-test` | `D:\data-warehouse\experiments\...` | 数仓实验目录 |
| `C:\apache-zookeeper-3.8.3-bin`、`C:\nssm` | `D:\AIWorker\tools\...` 或保留 | 测试/服务工具 |

### P2：暂不迁移，只记录

| 对象 | 目标建议 | 原因 |
|------|----------|------|
| `C:\tmp\dolphinscheduler`、`C:\tmp\multica-gateway-test`、`C:\tmp\openclaw` | 先归档后清理 | 测试/临时目录 |
| `C:\home\wukong\.hermes` | 备份后确认是否仍使用 | 可能是旧 profile |
| `C:\inetpub` | 只记录 | 未确认是否使用 IIS |

---

## 008 不建议迁移清单

| 对象 | 原因 |
|------|------|
| `C:\Windows`、`C:\ProgramData\Microsoft`、系统服务目录 | 系统组件，迁移会导致系统不稳定 |
| `C:\Program Files\ToDesk` | 有 Windows Service，需安装器迁移 |
| `C:\Program Files\Wukong` | 应通过安装器或配置迁移 |
| `C:\Program Files\nodejs`、`C:\Program Files\Git`、`C:\Program Files\Eclipse Adoptium` | 工具链建议重装，不建议直接搬目录 |
| `pagefile.sys`、`hiberfil.sys`、`swapfile.sys` | 系统文件 |
| `C:\Users\*\AppData\Local\Temp` | 临时目录，可重建 |
| `C:\Users\*\AppData\Local\Programs\kimi-desktop` | 安装器管理的桌面程序，建议重装 |
| `C:\Users\*\AppData\Local\智灵云2026` | 安装器管理的桌面程序，建议重装 |
| `C:\Users\*\AppData\Local\Programs\@multicadesktop` | 安装器管理的桌面程序，建议重装 |

---

## 009 推荐 D 盘统一目录结构

```
D:\AIStack\
├── runtime\
│   ├── cc-connect\
│   ├── clawai\
│   ├── codex\
│   ├── claude\
│   ├── kimi\
│   ├── multica\
│   ├── openclaw\
│   └── hermes-legacy\
├── launchers\
│   ├── start-cc-connect.ps1
│   ├── start-clawpilot-relay.ps1
│   ├── start-multica-daemon.ps1
│   └── start-mainbrain-guardian.ps1
├── profiles\
│   ├── 39169\
│   └── hermes\
└── reports\

D:\AIWorker\
├── agent-tools\
│   ├── Python312\
│   └── npm\
├── llm-wiki\
└── scripts\

D:\data-warehouse\
├── 01-dbt-duckdb\
├── shell\
└── experiments\

D:\AIBackups\
└── c-drive-pre-migration-YYYYMMDD\
    ├── hermes-profile\
    ├── 39169-profile\
    └── system-config-export\
```

---

## 010 迁移前置条件

1. **停止相关服务/计划任务**：
   - 暂停 `cc-connect-daemon`、`clawpilot-relay`、`MulticaGitGateway*`、`MainbrainWindowsGuardianHost` 等计划任务。
   - 停止 Multica daemon、Codex、Claude 等正在运行的 Agent 进程。

2. **完整备份**：
   - 复制 `C:\Users\hermes` 和 `C:\Users\39169` 下的相关隐藏目录到 `D:\AIBackups\c-drive-pre-migration-YYYYMMDD`。
   - 备份计划任务 XML：`Export-ScheduledTask`。
   - 备份环境变量：`[System.Environment]::GetEnvironmentVariables()`。
   - 备份快捷方式清单。

3. **记录当前状态**：
   - 记录所有计划任务状态（Running/Ready/Disabled）。
   - 记录所有服务状态。
   - 记录 PATH 和其他关键环境变量。
   - 记录所有快捷方式目标路径。

4. **准备 D 盘目标目录**：
   - 确保 D 盘有足够空间（建议预留 C 盘相关目录总大小的 2 倍）。
   - 创建 `D:\AIStack`、`D:\AIWorker`、`D:\data-warehouse`、`D:\AIBackups` 目录结构。

---

## 011 迁移步骤草案（只写方案，不执行）

### 阶段一：准备（冻结状态）

1. 导出所有计划任务 XML 到 `D:\AIBackups\tasks-export\`。
2. 导出系统/用户环境变量到 `D:\AIBackups\env-export\`。
3. 导出服务列表：`Get-Service | Export-Csv`。
4. 停止所有 P0 级计划任务和相关进程。
5. 创建完整文件备份：`robocopy C:\Users\hermes\.cc-connect D:\AIBackups\... /MIR`。

### 阶段二：分批迁移

**第一批：运行时脚本和非敏感配置**
- 迁移 `mainbrain` 守护脚本到 `D:\AIStack\mainbrain\`。
- 迁移 `.cc-connect`、`.clawai` 启动脚本到 `D:\AIStack\runtime\`。
- 更新计划任务指向新路径。

**第二批：状态目录和会话目录**
- 迁移 `.codex`、`.claude`、`.kimi`、`.openclaw` 状态目录。
- 迁移 `.multica`（合并两个 profile 的 multica 数据）。
- 迁移 `.hermes`（旧版 Hermes 数据）。

**第三批：历史/临时目录**
- 归档 `C:\tmp\*` 测试目录。
- 归档 `C:\root\*` 历史残留。
- 清理确认无用的目录。

### 阶段三：更新入口

1. 更新计划任务动作路径到 D 盘。
2. 更新桌面/开始菜单快捷方式目标路径。
3. 更新 `.bat` 启动脚本中的路径引用。
4. 更新环境变量（如 `MULTICA_CLAUDE_PATH`）。

### 阶段四：验证

1. 验证计划任务状态：`Get-ScheduledTask -TaskName "cc-connect-daemon"`。
2. 验证 Multica daemon：`multica issue list --limit 20 --output json`。
3. 验证 Codex/Claude/Kimi 登录状态和会话恢复。
4. 验证快捷方式有效性。
5. 验证数仓相关路径：`D:\data-warehouse\01-dbt-duckdb` 正常访问。

### 阶段五：恢复自动任务

- 只在验证通过后启用计划任务。
- 监控 24 小时，确认无异常后标记迁移完成。

---

## 012 回滚方案

1. **停止新 D 盘入口**相关计划任务和进程。
2. **从备份恢复**原 C 盘目录：`robocopy D:\AIBackups\c-drive-pre-migration-YYYYMMDD\hermes-profile C:\Users\hermes\.cc-connect /MIR`。
3. **恢复计划任务** XML：`Register-ScheduledTask -Xml (Get-Content backup.xml | Raw)`。
4. **恢复环境变量**：PATH、`MULTICA_CLAUDE_PATH` 等。
5. **恢复快捷方式**目标路径。
6. **重新启动**原计划任务。
7. **验证回滚成功**：
   - `multica issue list` 正常返回。
   - Codex/Claude/Kimi 登录状态正常。
   - 计划任务状态为 Running/Ready。

---

## 013 立即修复建议（低风险，无需等待完整迁移）

1. **修正 `Kimi.lnk` 和 `Kimi-修复版.lnk`** 到 `C:\Users\39169\AppData\Local\Programs\kimi-desktop\Kimi.exe`。
2. **修正 `智灵云2026.lnk`** 到 `C:\Users\39169\AppData\Local\智灵云2026\zlincloud.exe`。
3. **修正 `C:\Users\hermes\Desktop\Multica-兼容模式.bat`** 到 `C:\Users\hermes\AppData\Local\Programs\@multicadesktop\Multica.exe`。
4. **将 `启动 Multica Daemon.bat` 改为统一调用**一个 D 盘 wrapper，不直接混用 `39169` 与 `hermes` profile。
5. **删除或禁用已确认失效的计划任务**（`WarehouseMonitorConsole*`、`DolphinStandalone*`）前，先导出备份。

---

## 014 安全与敏感信息

| 位置 | 风险类型 | 处理建议 |
|------|----------|----------|
| `C:\Users\39169\.hermes\.env` | 存在 API key/token | 迁移前脱敏或加密 |
| `C:\Users\39169\.hermes\config.yaml` | 存在服务配置 | 迁移前审查敏感字段 |
| `C:\Users\hermes\.kimi\credentials` | 存在登录凭证 | 迁移后需重新验证 |
| `C:\Users\hermes\.claude\settings.json` | 可能存在 API key | 迁移前审查 |
| `C:\Users\39169\AppData\Local\Temp\polardb-tunnel.ps1` | 临时目录中的隧道脚本 | 高风险，建议删除 |
| 各 `.env` 文件 | 可能存在数据库连接串 | 只记录"存在敏感信息"，不输出原文 |

---

## 015 因权限/工具限制未执行项

| 未执行项 | 原因 | 建议 |
|----------|------|------|
| 实时 C 盘目录扫描 | 当前执行节点为 Linux，无法直接访问 Windows C 盘文件系统 | 需在 Windows 节点本地执行 `Get-ChildItem -Recurse` |
| 注册表读取 | 无 Windows 注册表访问能力 | 需在 Windows 节点执行 `reg query` |
| WMI 服务详细信息 | 无 `wmic` 或 PowerShell WMI 访问 | 需在 Windows 节点执行 `Get-WmiObject` |
| 实时环境变量读取 | 无法访问 Windows 节点实时环境 | 需在 Windows 节点执行 `[System.Environment]::GetEnvironmentVariables()` |
| 快捷方式目标解析 | 无 Windows COM 对象访问 | 需在 Windows 节点执行 `(New-Object -ComObject WScript.Shell).CreateShortcut(...)` |
| 增量扫描 | SSH jump 主机（111.229.153.11:22）当前不可达 | 检查网络/防火墙/SSH 服务状态 |

---

## 016 验收对照

| 验收项 | 状态 |
|--------|------|
| 输出 Windows C盘核心部署物清单 | ✅ 已完成 |
| 输出 Agent/OpenClaw/Hermes/数仓/监控相关目录 | ✅ 已完成 |
| 输出 Python/Node/工具链相关路径 | ✅ 已完成 |
| 输出服务、计划任务、快捷方式、环境变量引用风险 | ✅ 已完成 |
| 输出可迁移到 D盘的候选清单 | ✅ 已完成 |
| 输出不建议迁移清单 | ✅ 已完成 |
| 输出 P0/P1/P2 迁移优先级 | ✅ 已完成 |
| 输出迁移前备份方案 | ✅ 已完成 |
| 输出迁移步骤草案 | ✅ 已完成 |
| 输出回滚方案 | ✅ 已完成 |
| 明确标注未执行迁移 | ✅ 已完成 |
| 标注执行环境限制和未执行项 | ✅ 已完成 |

---

## 017 最终建议

1. **不建议一次性搬家**：C 盘部署物涉及两个用户 profile、多个运行中计划任务、跨 profile 快捷方式引用，风险较高。
2. **优先做 D 盘标准化**：先建立 `D:\AIStack\runtime\`、`D:\AIStack\launchers\` 统一目录，再逐步迁移。
3. **先修坏链，再迁目录**：立即修复 Kimi/智灵云/Multica 兼容模式的失效快捷方式，降低日常操作风险。
4. **分批验证**：每批迁移后验证 24 小时，确认无异常后再进行下一批。
5. **保留 C 盘备份至少 30 天**：确认 D 盘运行稳定后再清理 C 盘旧目录。
6. **下一步动作**：进入"受控迁移任务"阶段，由 Runtime 首脑审批后执行具体迁移操作。

---

*报告结束。本任务未执行任何文件移动、服务修改或环境变量变更。*
