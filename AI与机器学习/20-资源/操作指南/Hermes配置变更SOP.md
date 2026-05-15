---
uid: "20.12"
title: "Hermes 配置变更 SOP"
type: howto
stage: connect
created: 2026-05-06
updated: 2026-05-08
tags: [devops, operations]
status: active
sources: [原始素材/文章/hermes-agent-best-practices.docx]
---

# Hermes 配置变更 SOP

> 适用场景：修改 model provider、API Key、base_url、或任何会影响推理端点的配置变更。

---

## 一、变更前检查清单

- [ ] 确认当前在线平台及用户数量（飞书/微信/PocketClaw）
- [ ] 确认当前 provider 和模型名称
- [ ] 确认新 provider 的 API Key 已获取并测试可用
- [ ] 确认新端点支持的 API 模式（chat_completions / codex_responses / anthropic_messages）
- [ ] 确认有 SSH 跳板机访问权限（用于快速回滚）

---

## 二、配置文件对照

变更时必须同步检查以下文件：

| 文件 | 作用 | 关键字段 |
|------|------|---------|
| `~/.hermes/config.yaml` | 主配置 | `model.provider`, `model.default`, `providers.*` |
| `~/.hermes/.env` | 环境变量 | `*_API_KEY`, `OPENAI_BASE_URL`, `API_SERVER_HOST` |
| `~/.clawai/hermes-sessions.json` | clawpilot 缓存 | `providerId`, `modelId` |
| `~/.hermes/sessions/*.json` | Hermes 本地 session | `provider`, `model` |

---

## 三、步骤

### Step 1: 备份当前配置

```bash
ssh jump "cp ~/.hermes/config.yaml ~/.hermes/config.yaml.$(date +%Y%m%d-%H%M%S)"
```

### Step 2: 修改 config.yaml

```bash
ssh jump "vim ~/.hermes/config.yaml"
# 或通过 sed 精确替换
# 例：更改 provider
# sed -i 's/provider: kimi-coding/provider: kimicode/g' ~/.hermes/config.yaml
```

### Step 3: 修改 .env（如需）

```bash
ssh jump "vim ~/.hermes/.env"
# 更新对应的 API Key 或端点地址
```

### Step 4: 清理状态缓存（必须）

```bash
# clawpilot session store
ssh jump "sed -i 's/\"providerId\": \"OLD_PROVIDER\"/\"providerId\": \"NEW_PROVIDER\"/g' ~/.clawai/hermes-sessions.json"

# Hermes 本地 sessions（如果确定旧 session 不需要保留）
ssh jump "for f in ~/.hermes/sessions/*.json; do sed -i 's/\"provider\": \"OLD_PROVIDER\"/\"provider\": \"NEW_PROVIDER\"/g' \"\$f\" 2>/dev/null || true; done"

# 如果想彻底重置：
# ssh jump "rm ~/.clawai/hermes-sessions.json"
```

### Step 5: 重启 Gateway

```bash
ssh jump "pkill -9 -f 'hermes_cli.main gateway' && sleep 2 && /tmp/start-gateway.sh"
# 或如果是 systemd service：
# ssh jump "systemctl restart hermes-gateway"
```

### Step 6: 验证 API 端点

```bash
# 健康检查
curl -s http://111.229.153.11:8642/health | jq .

# 聊天测试
curl -s -X POST http://111.229.153.11:8642/v1/chat/completions \
  -H "Authorization: Bearer \$(ssh jump 'grep API_SERVER_KEY ~/.hermes/.env | cut -d= -f2')" \
  -H "Content-Type: application/json" \
  -d '{"model":"hermes-agent","messages":[{"role":"user","content":"test"}],"max_tokens":10}'
```

### Step 7: 验证各平台

| 平台 | 验证方式 |
|------|---------|
| 飞书 | 发送消息，观察响应 |
| 微信 | 发送消息，观察响应 |
| PocketClaw | 发送消息，观察是否有"模型错误" |

---

## 四、回滚方案

如果变更后某平台无法使用：

```bash
# 1. 恢复配置
ssh jump "cp ~/.hermes/config.yaml.BACKUP_TIMESTAMP ~/.hermes/config.yaml"

# 2. 清理新 provider 的缓存
ssh jump "sed -i 's/\"providerId\": \"NEW_PROVIDER\"/\"providerId\": \"OLD_PROVIDER\"/g' ~/.clawai/hermes-sessions.json"

# 3. 重含 Gateway
## 相关

- [[PocketClaw模型错误]] +> — 具体的 PocketClaw "模型错误" 排查案例
- [[Hermes最佳实践]] ^> — Hermes Agent 一般性配置指南
- [[HermesAgent全面审计]] +> — 全面自检报告
- [[记忆系统优化]] +> — 记忆系统优化方案

---

## 五、常见错误

### "Provider 'xxx' is set but no API key was found"
- 根因：缓存中的 provider 与 `.env` 中的 API Key 环境变量不匹配
- 解决：检查 `hermes-sessions.json` 和 `sessions/*.json` 中的 provider 是否已更新

### "Port 8642 already in use"
- 根因：Gateway 残留进程未退出
- 解决：`pkill -9 -f 'hermes_cli.main gateway'`, 等待 2 秒后重启

### clawpilot "relay disconnected"
- 根因：Gateway 重启后 api_server 未及时恢复
- 解决：clawpilot 会自动重连，如果长时间断开检查 api_server 端口是否监听

---

## 六、进阶：使用 custom provider 简化变更

> **核心思想**：放弃内置 provider registry（`kimi-coding`、`anthropic` 等），改用 `custom` provider 定义自有端点。这样 provider 名称由你自己控制，不会因 Hermes 版本升级而失效。

### 为什么推荐

| 维度 | 内置 provider | custom provider |
|------|--------------|-----------------|
| 名称稳定性 | 随版本可能变更（如 `kimi-coding` → `kimicode`） | 名称固定，如 `my-kimi` |
| session 缓存兼容性 | 改名后所有 session 缓存失效 | 无需关心改名问题 |
| 端点灵活性 | 受限于内置 registry 的 base_url | 完全自定义 |
| 环境变量依赖 | 必须匹配内置 registry 的 `*_API_KEY` 命名 | 统一用 `OPENAI_API_KEY` 或自定义 key |

### 配置方式

在 `config.yaml` 中定义 `custom_providers`：

```yaml
model:
  provider: custom
  default: my-kimi
  base_url: https://api.kimi.com/coding/v1

custom_providers:
  - name: my-kimi
    model: kimi-k2.6
    base_url: https://api.kimi.com/coding/v1
    api_key: sk-xxx  # 或留空，从 .env 的 OPENAI_API_KEY 读取
    key_env: OPENAI_API_KEY
    api_mode: chat_completions
```

### 变更简化效果

使用 custom provider 后，**Step 4（清理状态缓存）不再需要处理 provider 名称变更**，因为名称永远不会变。整个流程简化为：

1. 修改 `config.yaml` 中 `custom_providers` 的 `base_url` 或 `api_key`
2. 修改 `.env`（如需）
3. 重启 Gateway
4. 验证

如果某端点彻底下线，只需改 `base_url` 指向新地址，所有 session 缓存继续有效。

### 注意事项

- `api_mode` 必须显式声明，因为 custom provider 无法自动推断（不像内置 provider 有硬编码映射）
- 如果同时使用多个端点（如国内/国外双线路），可定义多个 custom provider，通过 `model.default` 或 PocketClaw 的 session model switch 切换
- `key_env` 可指向任意环境变量名，不一定要遵循内置 provider 的命名规范

---

## 七、Key 分离原则（多实例场景）

> **场景**：同一用户拥有多个 Hermes Agent 实例（如 111 服务器 + PocketClaw 本地），需要为不同实例分配独立的 API Key，避免单 key 泄露影响全局。

### 为什么需要分离

| 风险 | 共用 Key | 分离 Key |
|------|---------|---------|
| 某实例 config 泄露 | 所有实例暴露 | 仅该实例受影响 |
| Kimi 控制台限流/封禁 | 所有实例同时失效 | 仅该实例受影响 |
| 费用追踪 | 无法区分各实例消耗 | 控制台可按 key 统计 |

### 实施步骤

**Step 1: 为每个实例生成独立 Key**

在 Kimi 控制台创建多个 Key，命名规范建议：
- `sk-kimi-111-gateway` — 111 服务器 gateway 专用
- `sk-kimi-pocketclaw` — PocketClaw 本地实例专用
- `sk-kimi-backup` — 备用/测试

**Step 2: 实例配置隔离**

111 服务器 `~/.hermes/config.yaml`：
```yaml
custom_providers:
  - name: my-kimi
    model: kimi-k2.6
    base_url: https://api.kimi.com/coding/v1
    api_key: sk-kimi-111-gateway  # 仅 111 使用
    api_mode: chat_completions
```

PocketClaw 本地（或另一服务器）`~/.hermes/config.yaml`：
```yaml
custom_providers:
  - name: my-kimi
    model: kimi-k2.6
    base_url: https://api.kimi.com/coding/v1
    api_key: sk-kimi-pocketclaw  # 仅 PocketClaw 使用
    api_mode: chat_completions
```

**Step 3: 轮换流程**

当需要更换某实例的 key 时：
1. 在 Kimi 控制台生成新 key
2. 直接替换该实例 `config.yaml` 中的 `api_key`
3. 重启该实例 gateway
4. 旧 key 在控制台删除或保留观察期
5. **其他实例完全无感知**

### 关键经验

- **不要通过 sed 批量替换所有 key** — 这会破坏分离原则。必须逐实例确认当前 key 再替换
- **备份命名要含实例标识** — 如 `config.yaml.111-backup`、`config.yaml.pc-backup`
- **gateway 日志检查** — 重启后看 `/tmp/gateway.log` 是否有 "Authentication failed"，可快速定位 key 错误
- **环境变量 vs 明文** — 如果服务器是多用户环境，建议把 key 放到 `~/.hermes/.env` 并设 `key_env: KIMI_API_KEY_111`，config.yaml 只留 `${KIMI_API_KEY_111}`，避免 ps/进程泄露

---

## 关联笔记

- [[PocketClaw模型错误]] +> — 具体的 PocketClaw "模型错误" 排查案例
- [[Hermes最佳实践]] ^> — Hermes Agent 一般性配置指南
