---
title: GitHub任务总线与网关手册
date: 2026-05-12
tags: [runtime, github, gateway, command-bus]
sources:
  - raw/staging/handbrain/handbrain-20260511/files/20260510-GitHub任务总线打通验证报告.md
  - raw/staging/handbrain/handbrain-20260511/files/20260510-任务建立机制变更方案.md
  - raw/staging/handbrain/handbrain-20260511/files/20260510-loop-heartbeat机制报告.md
status: stable
---

# GitHub任务总线与网关手册

## 1. 结论

GitHub 适合作为任务入口、审计记录和知识沉淀层；网关适合作为受控转换器，把文件式指令转换为运行系统可识别的动作。GitHub 不应被当作实时运行态真相，网关也不应承担主脑职责。

## 2. 适用范围

适用于 GitHub Issue、runtime-commands、pending/done/failed 审计链路、dry-run 指令、approved 指令和运行状态回写。

## 3. 已确认事实

- GitHub 任务总线已经验证可打通；
- command file 模式具备审计性；
- dry-run 是低风险验证入口；
- approved 必须有明确范围和审批语义；
- 网关日志、done JSON、failed JSON 是重要证据。

## 4. 核心规则

1. 默认 dry-run；
2. approved 必须写明动作、范围、审批人和禁止事项；
3. done/failed 必须生成结构化审计文件；
4. pending 中已有 done 的命令不再重复处理；
5. GitHub 只做入口和审计，不替代 Runtime 总账；
6. 网关不得直接修改生产系统。

## 5. 操作流程

1. 用户或 ChatGPT 生成 command file 或 GitHub Issue；
2. 网关读取 pending；
3. 校验 mode、approval、禁止范围；
4. dry-run 只渲染命令；
5. approved 执行有限动作；
6. 写入 done 或 failed；
7. index/log 或报告记录结果。

## 6. 风险与限制

- GitHub 同步有延迟；
- 本地 gateway 权限可能和用户授权不一致；
- 任务创建成功不代表执行完成；
- 过多 command file 会让 GitHub 变成临时队列，而非知识库。

## 7. 待裁决事项

- 是否保留 command file 作为新主链路入口；
- approved 的审批字段是否标准化；
- done/failed JSON 是否长期归档或定期清理。

## 8. 后续动作

- 建立 command schema；
- 建立网关健康检查；
- 建立 done/failed 汇总报告；
- 与 Runtime Flow Guard 对齐状态字段。

## 9. 来源路径

- `raw/staging/handbrain/handbrain-20260511/files/20260510-GitHub任务总线打通验证报告.md`
- `raw/staging/handbrain/handbrain-20260511/files/20260510-任务建立机制变更方案.md`
- `raw/staging/handbrain/handbrain-20260511/files/20260510-loop-heartbeat机制报告.md`
