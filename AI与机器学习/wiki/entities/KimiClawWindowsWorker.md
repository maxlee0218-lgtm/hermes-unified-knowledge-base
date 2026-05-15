---
title: "KimiClawWindowsWorker"
type: entity
tags: [windows, worker, readonly]
sources: []
raw: []
last_updated: 2026-05-10
status: stable
---
# KimiClawWindowsWorker

## Role

Windows 本地只读执行节点。

## Responsibilities

读取 Windows C/D 盘结构摘要，检查 D:\AIWorker，补齐 Windows 环境证据。

## Boundaries

不连接生产，不迁移文件，不读取密钥原文，不绕过 Runtime治理者。
