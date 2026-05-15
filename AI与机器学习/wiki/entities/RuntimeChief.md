---
title: "RuntimeChief"
type: entity
tags: [runtime, governance]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# RuntimeChief

## Role

Runtime 治理 owner，负责运行态巡检、生命周期治理、堵点识别、状态收口建议。

## Responsibilities

读取 Multica 与 GitHub 状态，输出 runtime-state 与治理报告，识别 review、blocked、done/archive、heartbeat 问题。

## Boundaries

不修改 Multica 框架，不修改生产系统，不补业务产物。
