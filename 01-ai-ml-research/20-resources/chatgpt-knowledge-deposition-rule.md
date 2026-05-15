# ChatGPT 学习与知识沉淀规则

> 创建时间：2026-05-10  
> 状态：生效  
> 适用范围：数仓重构、AI智能体协同、Windows测试环境、dbt模型、速程监控、AI读数、成熟方案研究

---

## 一、核心规则

ChatGPT 不只是对话入口，也是本项目的统一方案裁决层和知识收敛层。

因此，ChatGPT 在项目过程中形成的以下内容，必须沉淀到 LLM Wiki，并推送 Git：

- 成熟方案研究结论；
- 框架学习结论；
- 业务方案；
- 架构判断；
- 阶段主路径；
- Go / Conditional Go / No-Go 判断；
- Agent协同规则；
- 数据治理方法论；
- 数仓重构方法论；
- dbt落地策略；
- 速程监控定位；
- AI辅助读数边界；
- 生产安全边界；
- 用户明确确认过的原则。

不能只停留在聊天记录里。

---

## 二、沉淀位置

### 2.1 长期知识

长期规则、业务方案、架构方案、成熟方案研究结论，沉淀到：

```text
/root/wiki/20-resources/
```

GitHub 对应目录：

```text
20-resources/
```

### 2.2 任务过程

具体任务文件进入：

```text
/root/wiki/tasks/inbox/
/root/wiki/tasks/active/
/root/wiki/tasks/review/
/root/wiki/tasks/done/
/root/wiki/tasks/archived/
```

### 2.3 状态观测

运行状态、heartbeat、任务状态进入：

```text
/root/wiki/tasks/status/
```

### 2.4 报告输出

阶段性报告可同时保存在：

```text
/root/multica-work/output/
/root/wiki/20-resources/
```

---

## 三、ChatGPT 学习输出格式

凡是 ChatGPT 基于外部成熟方案、官方文档、框架、项目案例形成的学习结果，必须按以下结构沉淀：

```markdown
# 标题

## 001 研究背景

## 002 参考来源
- 来源名称
- URL或出处
- 类型：official_doc / framework / open_source_project / case_study / engineering_blog / paper
- 相关性：high / medium / low

## 003 核心结论

## 004 对当前项目的适配判断

## 005 可立即采用的做法

## 006 不适合当前阶段的做法

## 007 推荐主路径

## 008 后续行动
```

---

## 四、100源研究专项要求

针对 `TASK-20260510-011-agentic-data-warehouse-100-source-research`：

- 不少于100个来源；
- 每个来源必须记录名称、出处、类别、关键结论、适用性判断；
- 不能只输出聊天总结；
- 必须沉淀到：

```text
/root/wiki/20-resources/agentic-data-warehouse-100-source-research.md
```

并推送 GitHub。

---

## 五、ChatGPT 与 Agent 的知识职责差异

### ChatGPT

负责：

- 最终方案收敛；
- 主路径判断；
- 阶段判断；
- 业务方案；
- 方法论归纳；
- 成熟方案适配；
- 用户决策问题收敛。

### Agent

负责：

- 事实摸排；
- 执行验证；
- 本地读取；
- 沙箱验证；
- 候选报告；
- 初步建议。

Agent 的报告是输入，ChatGPT 的收敛结论必须另行沉淀。

---

## 六、Git 提交要求

每次重要知识沉淀必须记录：

- 文件路径；
- commit id；
- 更新时间；
- 是否已 push；
- 是否作为后续任务基线。

未推送 GitHub 的内容，只能视为本地草稿，不能视为正式知识闭环。

---

## 七、禁止事项

禁止：

- 只在聊天里形成关键方案，不沉淀；
- 只让 Agent 沉淀，ChatGPT 自己不沉淀；
- 没有来源就伪装成成熟方案；
- 将未验证观点写成事实；
- 将敏感信息写入 Git；
- 将生产密钥、token、连接串、密码写入 Wiki/Git。

---

## 八、当前生效原则

从本规则创建后，所有与当前项目有关的重要学习、判断、方案、阶段结论，都必须：

```text
聊天中说明
→ Wiki 中沉淀
→ GitHub 中版本化
→ 后续任务引用
```

这条规则同时约束 ChatGPT、主脑和所有 Agent。
