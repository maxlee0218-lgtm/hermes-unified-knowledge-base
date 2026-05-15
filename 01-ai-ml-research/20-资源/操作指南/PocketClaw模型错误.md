---
uid: "20.11"
title: "PocketClaw + Hermes Gateway '模型错误' 排查"
type: howto
stage: connect
created: 2026-05-06
updated: 2026-05-08
tags: [devops, troubleshooting]
status: active
sources: [原始素材/文章/hermes-agent-best-practices.docx]
---

# PocketClaw + Hermes Gateway "模型错误" 排查

## 故障现象

PocketClaw（Clawai iOS App）通过 `clawpilot` 配对 Hermes Gateway 后，设备状态在线，但发送消息时 App 提示 **"模型错误"**。

## 根因

clawpilot 在本地持久化了每个 session 的 `modelId` 和 `providerId`。当 Hermes 的 `config.yaml` 中 provider 名称变更后（如 `kimi-coding` → `kimicode`），clawpilot 的 session store 仍向 Hermes 传递旧 provider，导致 Hermes 的 `AIAgent` 初始化时找不到对应 API Key，抛出 RuntimeError。

关键链路：

```
PocketClaw → clawpilot relay → Hermes API (/v1/chat/completions)
                ↓
         session-store.json 缓存旧 provider
                ↓
         hermes_agent_bridge.py 调用 AIAgent(provider='kimi-coding')
                ↓
         RuntimeError: Provider 'kimi-coding' is set but no API key was found
```

## 排查步骤

1. **确认 relay 状态**
   ```bash
   pm2 show clawpilot          # 或 /usr/lib/node_modules/.../pm2/bin/pm2 show clawpilot
   # 状态应为 online，relay 与 cloud 已连接
   ```

2. **查看 relay 日志**
   ```bash
   tail -n 100 ~/.clawai/clawpilot.log
   # 关注 chat.send 是否收到请求
   ```

3. **查看 Hermes agent 日志**
   ```bash
   tail -n 50 ~/.hermes/logs/agent.log
   tail -n 50 ~/.hermes/logs/errors.log
   # 寻找 RuntimeError 或 Provider 相关的报错
   ```

4. **检查 session store 中的 provider 缓存**
   ```bash
   cat ~/.clawai/hermes-sessions.json
   # 检查各 session 的 providerId 是否与 config.yaml 一致
   ```

5. **验证 Hermes API 本身正常**
   ```bash
   curl -X POST http://127.0.0.1:8642/v1/chat/completions \
     -H "Authorization: Bearer $API_SERVER_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"hermes-agent","messages":[{"role":"user","content":"test"}]}'
   # 若此请求正常，说明问题在 relay → bridge → agent 链路
   ```

## 修复方法

### 方案 A：清理缓存的 session provider（推荐）

```bash
# 1. 修改 ~/.clawai/hermes-sessions.json 中的旧 provider
sed -i 's/"providerId": "kimi-coding"/"providerId": "kimicode"/g' ~/.clawai/hermes-sessions.json

# 2. 同时清理 Hermes 本地 session 中残留的 provider 信息（可选）
for f in ~/.hermes/sessions/*.json; do
  sed -i 's/"provider": "kimi-coding"/"provider": "kimicode"/g' "$f" 2>/dev/null || true
done
```

### 方案 B：彻底重置（更彻底但会丢失 session 历史）

```bash
# 停止 relay
pm2 stop clawpilot

# 删除 clawpilot session store
rm ~/.clawai/hermes-sessions.json

# 重新配对（在服务器上执行）
clawpilot pair --runtime hermes

# 在 PocketClaw App 中输入新的 Access Code
```

## 预防措施

1. **变更 provider 后主动清理状态**
   - 修改 `config.yaml` 中的 `model.provider` 后，顺手检查 `~/.clawai/hermes-sessions.json` 和 `~/.hermes/sessions/*.json`。

2. **使用 provider alias 保持一致性**
   - 尽量使用 `custom` provider 模式（`custom_providers`）定义自有端点，避免依赖内置 provider 名称变更。

3. **日志优先**
   - PocketClaw 报错时，先看 `~/.clawai/clawpilot.log` 和 `~/.hermes/logs/errors.log`，不要先猜网络或端口问题。

## 关联笔记

- [[20-resources/concepts/hermes-agent-gateway|Hermes Agent Gateway]] ^> 延伸
- [[20-resources/howtos/ssh-jump-host-setup|SSH 跳板机配置]] -> 支持
