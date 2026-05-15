# ChatGPT 亲自负责 100 源研究规则

> 创建时间：2026-05-10  
> 状态：生效  
> 适用范围：AI智能体驱动数仓重构、dbt、Dolphin/DataX、Windows测试环境、速程监控、Agent协同、AI读数

---

## 一、纠偏结论

用户要求“读100篇/100个成熟方案、框架、项目”，该责任主体是 ChatGPT，不是深度研究智能体。

深度研究智能体可以作为辅助资料收集者，但不能替代 ChatGPT 完成最终阅读、判断、取舍和主路径收敛。

---

## 二、职责划分

### ChatGPT 必须亲自负责

- 选择研究方向；
- 阅读关键来源；
- 判断来源质量；
- 判断是否适配当前项目；
- 反对不适合当前阶段的方案；
- 收敛成当前项目主路径；
- 形成最终业务/架构建议；
- 将学习结论写入 Wiki/Git。

### 深度研究智能体只能辅助

- 收集候选链接；
- 做初步摘要；
- 按分类整理材料；
- 标记可能相关的来源。

其输出只能作为输入，不能作为最终结论。

---

## 三、100 源研究交付标准

每个来源必须记录：

```yaml
id: SRC-XXX
name: 来源名称
url_or_source: URL或出处
category: Agent / GitOps / Warehouse / dbt / Orchestration / Data Quality / Observability / Semantic Layer / Production Safety / Documentation
source_type: official_doc / framework / open_source_project / case_study / engineering_blog / paper
chatgpt_read_status: unread / skimmed / read
key_takeaway: 关键结论
fit_for_current_project: high / medium / low / not_now
usable_now: yes / later / no
chatgpt_judgement: ChatGPT最终判断
recommended_action: 当前项目采用/暂缓/反对
```

---

## 四、沉淀位置

ChatGPT 自己的研究主文件：

```text
20-resources/chatgpt-100-source-research-log.md
```

最终收敛报告：

```text
20-resources/chatgpt-agentic-warehouse-main-path-after-100-sources.md
```

---

## 五、当前规则

从本规则创建后，100 源研究不以 Agent 报告为最终成果。

最终成果必须由 ChatGPT 亲自收敛，并进入 GitHub。

---

## 六、当前项目约束

所有研究结论必须回到当前约束：

- 生产不动；
- Windows测试环境先行；
- AI只建议不碰生产；
- dbt旁路引入；
- Dolphin保留编排；
- DataX保留同步；
- 速程监控做生产护栏；
- ChatGPT统一方案裁决；
- 用户人工执行生产动作。
