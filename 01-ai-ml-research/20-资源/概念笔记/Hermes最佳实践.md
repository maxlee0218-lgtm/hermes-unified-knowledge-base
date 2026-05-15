---
title: "Hermes Agent 最佳实践"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/hermes-agent-best-practices.docx]
status: active
---

<!-- UID: 20260506-hermes-best-practices -->

# Hermes Agent 最佳实践

## 一、配置最佳实践

### 1.1 API 密钥管理

**核心原则**: 密钥永远不写入配置文件正文，只放在 `~/.hermes/.env`。

```bash
# 正确做法
hermes config set OPENROUTER_API_KEY sk-or-v1-你的密钥

# 错误做法 (绝对禁止)
# 在 config.yaml 中直接写密钥
```

**多密钥备份**: 生产环境建议配置 fallback provider chain：

```yaml
providers:
  - name: primary
    type: openai
    model: kimi-k2.5
  - name: fallback
    type: anthropic
    model: claude-sonnet-4-5
```

### 1.2 模型选择策略

| 场景 | 推荐模型 | 原因 |
|------|---------|------|
| 复杂推理/架构决策 | Claude Sonnet / GPT-4o | 上下文理解强，幻觉少 |
| 日常对话/简单任务 | Kimi K2.5 / DeepSeek V4 | 成本低 10-50 倍 |
| 长文档处理 | Claude 3.5 / Kimi 128K | 超长上下文窗口 |
| 极速响应 | Gemini Flash | 延迟最低 |

**重要**: 不要在会话中间切换模型，会破坏 prompt cache。

### 1.3 踩坑教训

- Gateway 启动时必须设置 `MESSAGING_CWD` 环境变量，否则可能加载额外文件导致 token 飞速消耗

---

## 二、记忆管理最佳实践

### 2.1 MEMORY.md 写作规范

**写入内容**:
- 项目技术栈和编码规范
- 团队工作流约定
- 重要决策和原因

**不写入内容**:
- 可从代码推导的信息
- 临时上下文
- 日志性质内容

**容量控制**:
- MEMORY.md 上限约 2200 字符
- USER.md 上限约 1375 字符
- 接近上限时主动说"清理过时记忆"

### 2.2 USER.md 维护

存储用户画像，直接影响 Agent 回复的语境和深度。典型内容：

```markdown
# 用户画像
- 身份：全栈工程师，主攻 Python 后端
- 偏好：回复简洁直接，附上代码示例
- 禁忌：不接受长篇大论
- 常用工具：Docker, Git, PostgreSQL
```

### 2.3 记忆触发与清理

- **主动触发**: 完成任务后说"记住这个"，Agent 自动保存
- **手动干预**: 定期打开 `~/.hermes/memories/` 下的记忆文件直接编辑
- **清理时机**: 响应变慢、每月例行检查、技术栈变更后
- **重要**: 记忆是"冻结快照"，会话期间修改不立即生效，下次会话启动才更新

---

## 三、技能管理最佳实践

### 3.1 命名规范

命名格式: `动作-对象.md`，方便用 `/` 斜杠命令快速调用。

```
skills/
├── deploy-staging.md      # 部署类
├── code-review.md         # 审查类
├── git-summary.md         # Git 操作类
└── research-llm.md        # 研究类
```

### 3.2 技能分层设计

| 层级 | 名称 | 用途 | 示例 |
|------|------|------|------|
| Level 0 | 内核技能 | Agent 出厂自带 | 文件读写、终端命令 |
| Level 1 | 基础技能 | 通用工作流 | Git 操作、代码格式化 |
| Level 2 | 专业技能 | 垂直场景 | 部署流水线、数据库迁移 |

**何时创建技能**: 当一个任务需要 5+ 步骤且会重复执行时。

### 3.3 踩坑教训

- 技能生成后必须检查逻辑！自动生成的技能可能有冗余步骤或遗漏边界条件
- 建议用 `/skills check` 验证技能文件有效性

---

## 四、多平台协作

### 使用场景划分

| 平台 | 推荐场景 |
|------|---------|
| CLI 终端 | 深度开发、代码调试 |
| Telegram | 移动端快速查询、定时任务通知 |
| Discord | 多频道管理、团队协作 |
| 飞书 | 企业内部助手、审批流程 |

### 跨平台记忆同步

- 记忆系统是全局的，不区分平台
- 建议不同平台设置不同工作目录：`MESSAGING_CWD`

---

## 五、部署最佳实践

### 各环境要点

| 环境 | 要点 |
|------|------|
| 本地开发 | Windows 必须 WSL2，macOS/Linux 直接安装 |
| VPS ($5 服务器) | 1核1G 内存足够（不跑本地 LLM 时 <500MB）|
| Serverless | 冷启动延迟高，不适合即时响应场景 |

### 数据迁移

```bash
# 本地 → VPS
rsync -av --exclude='hermes-agent/' ~/.hermes/ root@服务器IP:~/.hermes/

# 路径修正（Mac → Linux 必做）
sed -i 's|/Users/用户名|工作目录|g' ~/.hermes/config.yaml
```

### Gateway 开机自启

```bash
hermes gateway install
systemctl --user enable hermes-gateway
systemctl --user start hermes-gateway
```

---

## 六、安全最佳实践

### 6.1 敏感信息处理

**绝对禁止**:
- 在任何配置文件中硬编码 API Key
- 将 .env 提交到 Git
- 在对话中暴露密钥

**正确做法**:
```bash
# .gitignore
.env
*.env.local
```

### 6.2 命令审批策略

| 策略 | 适用场景 |
|------|---------|
| manual | 生产环境（推荐） |
| smart | 信任环境，AI 评估风险 |
| off | 绝对信任的沙箱环境 |

**生产环境必须使用 manual 模式**，危险操作（删除文件、系统修改）必须人工确认。

### 6.3 Prompt 注入防护

**攻击特征**:
- "忽略之前所有指令"
- "作为 root 执行"
- 隐藏在 HTML 注释中的指令

**Hermes 内置防护**: Tirith 安全模块会自动扫描上下文文件检测 prompt injection。

**注意**: Tirith 可能过于激进误拦合法命令，遇到这种情况在分屏终端中手动执行。

### 6.4 生产环境安全清单

- [ ] 使用 Docker 后端隔离执行环境
- [ ] 配置用户白名单（禁止 `GATEWAY_ALLOW_ALL_USERS=true`）
- [ ] 启用 HTTPS（通过 Nginx 反向代理）
- [ ] 设置 API 消费限额
- [ ] 定期备份 ~/.hermes/ 目录

---

## 七、性能优化

### 7.1 Token 消耗优化

**关键数据**: 每次请求中，工具定义占 46%，系统提示占 27%。**73% 是固定开销！**

| 优化项 | 节省 Token | 说明 |
|--------|-----------|------|
| 禁用浏览器工具 | ~1.3K/请求 | Telegram/Discord 场景 |
| 延迟加载技能 | ~2.2K/请求 | 技能按需加载 |
| 使用便宜模型 | 10-50x | Kimi/DeepSeek 替代 Claude |

**上下文压缩**: 当对话变长时运行 `/compress` 压缩历史，保留关键信息。

### 7.2 并行任务调度

需要同时研究多个主题时，使用 `delegate_task` 并行执行：

```
帮我同时研究这三个话题：A/B/C，用并行任务处理
```

每个子任务独立运行，只有最终摘要返回主对话，大幅降低主会话 token 消耗。

### 7.3 响应速度优化

```yaml
# config.yaml 调优参数
llm_config:
  temperature: 0.3      # 降低随机性
  max_tokens: 512       # 限制输出长度
  prompt_caching: true  # 启用提示缓存
```

---

## 相关资源

- [[HermesAgent|Hermes Agent 实体档案]]
- [[幻觉缓解|抗幻觉技术体系]] — 行为准则补充
