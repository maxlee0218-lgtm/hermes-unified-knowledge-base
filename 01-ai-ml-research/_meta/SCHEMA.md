---
title: "Wiki Schema — 知识库宪法"
created: 2026-05-06
updated: 2026-05-06
stage: evergreen
type: concept
tags: [thinking, reference]
status: active
---

<!-- UID: 20260506-schema -->

# Wiki Schema — 知识库宪法

> 本文件是知识库的最高准则。借鉴 Karpathy LLM Wiki + Zettelkasten + PARA + Evergreen Notes 方法论，设计一个可长期维护的个人知识系统。Hermes 必须严格执行。
> 版本: v2.5 | 最后更新: 2026-05-06

---

## 0. 核心哲学

> **笔记不是用来存的，是用来想清楚的。**

知识库的本质是**外化思维**（externalized cognition），不是剪藏夹。每篇笔记必须是你思考的产物，而非原文的搬运。

四大支柱：
- **原子化**：一个想法一篇笔记，可独立理解
- **链接化**：知识的价值在于连接，不在孤立存储
- **渐进式**：笔记从粗糙到精炼，需要多次迭代
- **行动导向**：笔记必须回答"这对我有什么用"

---

## 1. 目录结构（PARA + Zettelkasten 融合）

```
├── _元数据/               # 元数据：SCHEMA、INDEX、日志、模板
│   ├── SCHEMA.md         # 本文件
│   ├── INDEX.md          # 知识库总地图（MOC）
│   ├── LOG.md            # 操作日志
│   └── templates/        # 笔记模板
│       ├── concept.md
│       ├── project.md
│       └── moc.md
├── 00-项目/         # Projects：有明确截止日期的任务（PARA）
│   ├── active/           # 正在进行
│   └── finished/         # 已完结
├── 10-领域/            # Areas：持续维护的责任领域（PARA）
│   ├── infra/            # 基础设施
│   ├── dev/              # 开发技术
│   ├── ml-ai/            # AI/ML
│   ├── finance/          # 财务
│   ├── health/           # 健康
│   └── life/             # 生活
├── 20-资源/        # Resources：主题性参考材料（PARA）
│   ├── concepts/         # 概念笔记（Evergreen）
│   ├── entities/         # 实体档案（人、工具、产品、论文）
│   ├── comparisons/      # 对比决策
│   └── howtos/           # 操作指南（How-to notes）
├── 30-内容地图/             # Maps of Content：内容地图
│   ├── agent-system.md   # Agent 知识体系地图
│   ├── ml-knowledge.md   # ML 知识体系地图
│   └── ...               # 按领域组织
├── 90-归档/          # Archives：不再活跃的内容（PARA）
│   ├── projects/         # 完结项目归档
│   └── notes/            # 过时笔记归档
└── 原始素材/                 # 原始素材（PDF/DOCX/MD/URL）
    ├── papers/
    ├── articles/
    └── transcripts/
```

**为什么用数字前缀**：Johnny Decimal 方法，让目录按逻辑排序而非字母排序。

---

## 2. 笔记类型

### 2.1 概念笔记（Concept / Evergreen Note）

**定义**：围绕一个想法、模型、原理的常青笔记。不依附于任何来源，可独立理解。

**特征**：
- 标题是**一个断言或概念**，不是一个话题
- 好标题：`ReAct 循环的本质是观察驱动的推理` | `Temperature 不是随机性参数`
- 坏标题：`ReAct 介绍` | `Temperature 学习笔记`
- 用自己的话写，不引用原文
- 长度：200-1000 字。超过拆分为子概念。

### 2.2 实体笔记（Entity）

**定义**：关于具体的人、公司、产品、工具、论文的档案。

**特征**：
- 客观事实为主，个人评价为辅
- 包含：是什么、关键数据、个人使用体验、与其他实体的关系

### 2.3 内容地图（MOC - Map of Content）

**定义**：某领域的导航中心，不是目录，是**思考的产物**。

**特征**：
- 回答"这个领域我掌握了什么"
- 列出该领域的概念笔记，并说明它们的关系
- MOC 本身也是一篇笔记，会演进

### 2.4 项目笔记（Project）

**定义**：围绕有截止日期的事物的笔记。

**特征**：
- 包含目标、里程碑、决策记录、教训
- 项目结束后移动到 `90-归档/projects/`

### 2.5 操作指南（How-to）

**定义**：步骤化的操作说明。

**特征**：
- 可执行、可复现
- 场景 + 步骤 + 验证方法

### 2.6 日志（Log）

**定义**：时间线记录。

**特征**：
- 按日期组织
- 包含做了什么、学到了什么、下一步计划

---

## 3. 笔记生命周期（渐进式总结）

笔记不是一次写成的，需要多次迭代：

```
原文投喂
    ↓
[阶段 0] Capture — 放入 原始素材/，不做任何处理
    ↓ 当需要学习时
[阶段 1] Digest — 快速阅读，高亮重点，写 3 句话总结
    ↓ 当需要深入时
[阶段 2] Distill — 用自己的话重写核心，形成概念笔记（200-500 字）
    ↓ 当概念成熟时
[阶段 3] Connect — 与已有笔记建立链接，更新 MOC
    ↓ 当理解深化时
[阶段 4] Evergreen — 精炼为可独立理解的常青笔记，作为知识体系的基石
```

**规则**：
- 不是所有笔记都需要到 Evergreen 阶段
- 只有真正改变你认知的才值得 Evergreen
- 大多数笔记停留在 Distill 或 Connect 阶段即可

---

## 4. Frontmatter 规范

```yaml
---
title: "断言式标题：一个完整的想法"
created: YYYY-MM-DD
updated: YYYY-MM-DD
stage: capture | digest | distill | connect | evergreen
type: concept | entity | moc | project | howto | log
tags: [topic, usage]      # topic 从受控词表选，usage 从用途词表选
sources: [原始素材/path/to/file]
status: active | dormant | archived
---
```

| 字段 | 说明 | 约束 |
|------|------|------|
| `title` | 断言式标题，不是话题 | 不含日期编号，不超过 50 字 |
| `created` | 创建日期 | 不变 |
| `updated` | 最后更新 | 每次修改更新 |
| `stage` | 渐进式阶段 | 五选一，反映笔记成熟度 |
| `type` | 笔记类型 | 六选一 |
| `tags` | topic + usage 组合 | 最多 2 个：1 主题 + 1 用途 |
| `sources` | 原始素材路径 | 可选 |
| `status` | 活跃状态 | 三选一 |

### 4.1 主题标签（Topic）

从以下受控词表中选择，**最多 1 个**：

```
ai-ml, infra, backend, frontend, devops, security, data, product,
finance, health, career, life, reading, thinking
```

**为什么限制为 1 个主题**：主题信息由目录结构承载。笔记放在哪里比给它打什么标签更重要。

### 4.2 用途标签（Usage）

从以下受控词表中选择，**最多 1 个**：

| 标签 | 含义 | 何时使用 |
|------|------|---------|
| `implement` | 准备落地 | 计划在近期项目中使用 |
| `reference` | 常备查阅 | 已掌握，需要时回来查 |
| `insight` | 重要洞见 | 改变了我的认知 |
| `decision` | 决策依据 | 基于它做过或将做决策 |
| `review` | 定期回顾 | 需要防止遗忘 |
| `wip` | 进行中 | 尚未完成，正在整理 |

### 4.3 状态（Status）

| 状态 | 含义 |
|------|------|
| `active` | 当前在关注/使用/迭代中 |
| `dormant` | 暂时不用，但未来可能激活 |
| `archived` | 已过时或不再相关，移到 90-归档/ |

---

## 5. 链接规范（核心中的核心）

知识的价值在于连接。链接不是装饰，是思维的延伸。

### 5.1 链接类型

每建立一个链接时，问自己：这是什么类型的关系？

| 关系 | 符号 | 含义 | 示例 |
|------|------|------|------|
| 支持 | `->` | 这篇笔记支持/证明那篇 | `[[temperature-tuning]] -> [[llm-sampling]]` |
| 反对 | `x>` | 这篇笔记反驳/限定那篇 | `[[temperature-high]] x> [[deterministic-output]]` |
| 延伸 | `+>` | 这篇笔记是那篇的深入/扩展 | `[[react-pattern]] +> [[agent-loop]]` |
| 应用 | `!>` | 这篇笔记是那篇的实践应用 | `[[rag-hybrid]] !> [[project-rag-chatbot]]` |
| 上位 | `^>` | 这篇笔记是那篇的上位概念 | `[[agent-architecture]] ^> [[react-pattern]]` |
| 下位 | `v>` | 这篇笔记是那篇的下位概念 | `[[tool-calling]] v> [[agent-architecture]]` |

**实践方式**：在"相关"区块用注释标明关系。

```markdown
## 相关
- [[llm-sampling]] ^> — 采样策略是温度调优的上位概念
- [[token-optimization]] +> — 温度调优是 Token 优化的子集
```

### 5.2 链接数量

- **概念笔记**：至少 3 个出站链接，至少 1 个入站链接
- **MOC**：链接该领域所有相关概念笔记
- **实体笔记**：至少 2 个链接到相关概念或项目

### 5.3 禁止

- 不要建立无意义的链接（如把所有笔记都连到 index）
- 不要建立空链接（指向不存在的笔记）
- 不要只在上位笔记链接下位，下位也必须链接上位

---

## 6. 内容规范

### 6.1 标题

- **断言式**：`Temperature 不是随机性参数，而是 softmax 权重的重新分配`
- **不是**：`Temperature 学习笔记`

### 6.2 开头

第一段不超过 3 句话，回答：
1. 这篇笔记的核心论点是什么？
2. 为什么重要？
3. 在什么场景下适用？

### 6.3 正文

- 用自己的话写，不是改写原文
- 可以引用原文，但必须标注出处
- 使用代码块、表格、列表降低认知负荷
- 长度：概念笔记 200-1000 字；MOC 不限；How-to 按步骤来

### 6.4 结尾

必须包含"相关"区块，列出链接和相关笔记。

---

## 7. 命名规范

### 7.1 文件名

- 中文命名，直观可读
- 示例：`ReAct循环.md`, `模型选择策略.md`
- 允许：`中文文件名.md`
- 目录名同样使用中文，如 `10-领域/开发技术/`、`20-资源/概念笔记/`

### 7.2 笔记 ID（Zettelkasten 风格）

在笔记内底部添加 UID，便于稳定引用：

```markdown
<!-- UID: 20260506-react-pattern -->
```

即使笔记改名，UID 不变，链接不会断。

---

## 8. 维护流程

### 8.1 新建笔记

1. 确定笔记类型和目录位置
2. 从 `_元数据/templates/` 复制对应模板
3. 填写 frontmatter
4. 撰写内容
5. 建立至少 3 个 wikilink
6. 更新相关 MOC
7. 在 LOG.md 记录
8. git commit

### 8.2 更新笔记

1. 更新 `updated` 字段
2. 如果内容有重大变化，更新 `stage`（如从 distill -> connect）
3. 检查链接是否仍然有效
4. 在 LOG.md 记录

### 8.3 归档笔记

1. 将 `status` 改为 `archived`
2. 将文件移动到 `90-归档/`
3. 在原位置放一个重定向 stub：
   ```markdown
   ---
   title: "【已归桡】xxx"
   archived: true
   redirect: "../../90-归档/notes/xxx.md"
   ---
   ```
4. 在 LOG.md 记录原因

### 8.4 定期 Review

每月一次：
1. 检查所有 `status: active` 的笔记，是否仍需 active
2. 检查所有 `stage: digest` 的笔记，是否需要推进到 distill
3. 检查孤立笔记（无入站链接的笔记），补充链接
4. 更新相关 MOC

---

## 9. Hermes 执行约束

1. **不执行未经用户确认的结构性变更**（如批量移动文件、重命名目录）
2. **每篇新笔记必须有模板、有 frontmatter、有链接、有 MOC 更新**
3. **不创建孤立笔记**：新建笔记必须有至少 3 个出站链接
4. **标签严格限制**：1 topic + 1 usage，新标签必须先在 SCHEMA 注册
5. **stage 必须如实反映**：不要一上来就标 evergreen，digest 就是 digest
6. **原始文件必须入库**：每篇笔记的 sources 必须指向 原始素材/ 下的真实文件
7. **操作必日志**：每次增删改必须在 LOG.md 记录
8. **格式走样 = 抗体**：用户指出后记录到自愈进化模块

---

## 10. 模板

见 `_元数据/templates/` 目录：
- `concept.md` — 概念笔记模板
- `entity.md` — 实体笔记模板
- `moc.md` — 内容地图模板
- `project.md` — 项目笔记模板
- `howto.md` — 操作指南模板
