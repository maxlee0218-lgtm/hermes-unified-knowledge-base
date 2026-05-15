---
title: "smolagents 框架入门"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-agent-basics.docx]
status: active
---

<!-- UID: 20260506-smolagents-framework -->

# smolagents 框架入门

## 最小示例

```python
from smolagents import CodeAgent, LiteLLMModel

model = LiteLLMModel(model_id="deepseek/deepseek-chat", temperature=0.7)
agent = CodeAgent(tools=[], model=model, add_base_tools=True)
result = agent.run("斐波那契数列的第 20 项是多少？")
```

三个核心要素：`tools`、`model`、`agent`。

## CodeAgent vs ToolCallingAgent

| 维度 | CodeAgent | ToolCallingAgent |
|------|-----------|------------------|
| 调用方式 | LLM 写 Python 代码 | LLM 输出 JSON 工具调用 |
| 效率 | 一步内多次调用 | 每步只能调一个 |
| 灵活性 | 支持循环、条件、变量 | 严格按步骤执行 |
| 安全性 | 低（执行任意代码） | 高（仅调用声明的工具） |
| 适用阶段 | 学习、原型 | 生产环境 |

**选择建议**：学习和原型用 CodeAgent，生产环境用 ToolCallingAgent 或 CodeAgent + 沙箱。

## 工具定义

### @tool 装饰器（简单无状态）

```python
from smolagents import tool

@tool
def get_current_time(timezone: str = "Asia/Shanghai") -> str:
    """
    获取指定时区的当前时间。
    Args:
        timezone: 时区名称，如 "Asia/Shanghai"
    """
    from datetime import datetime
    import zoneinfo
    return datetime.now(zoneinfo.ZoneInfo(timezone)).strftime("%Y-%m-%d %H:%M:%S")
```

**三个关键点**：函数名就是工具名；docstring 是 LLM 理解工具的唯一依据；类型注解告诉 LLM 参数类型。

### Tool 子类（复杂有状态）

```python
from smolagents import Tool

class UnitConverter(Tool):
    name = "unit_converter"
    description = "单位换算工具"
    inputs = {
        "value":   {"type": "number", "description": "要转换的数值"},
        "from_unit": {"type": "string", "description": "原始单位"},
        "to_unit":   {"type": "string", "description": "目标单位"},
    }
    output_type = "string"

    def forward(self, value: float, from_unit: str, to_unit: str) -> str:
        # 换算逻辑...
        pass
```

**选择**：简单无状态用 `@tool`，复杂有状态用 `Tool` 子类。

## 内部机制

### System Prompt

smolagents 使用 Jinja2 模板，在初始化时把工具描述、managed_agents 信息注入 System Prompt。

```python
agent = CodeAgent(tools=[], model=model, add_base_tools=True)
print(agent.prompt_templates["system_prompt"][:500])
```

还可通过 `instructions` 追加自定义指令：

```python
CodeAgent(tools=[], model=model, instructions="你是一个数学教授。回答时用通俗易懂的方式解释。")
```

### 执行日志

```python
for i, step in enumerate(agent.logs):
    if hasattr(step, "model_output"):
        print(f"Step {i}: {step.model_output[:200]}...")
    if hasattr(step, "observations"):
        print(f"Observation: {step.observations[:200]}...")
```

### 记忆管理

```python
messages = agent.write_memory_to_messages()
```

把 System Prompt 和每个执行步骤转换为消息格式，作为下一步的上下文。

## Agent 调控三板斧

| 参数 | 作用 | 建议 |
|------|------|--------|
| `max_steps` | 防止无限循环 | 简单 2-3，复杂 8-10 |
| `instructions` | 定制 Agent 人设 | 追加到 System Prompt 末尾 |
| `planning_interval` | 每 N 步反思一次 | 复杂任务设为 2-3 |

```python
planning_agent = CodeAgent(
    tools=[search_database],
    model=model,
    planning_interval=2,  # 每 2 步反思一次
    max_steps=8,
)
```

## 相关

- [[LLM与Agent基础|LLM 和 Agent 基础]] — 源文档
- [[ReAct模式|ReAct 循环与手写实现]] — 原理层
- [[Agent生产安全|Agent 生产环境安全]] — CodeAgent 必须配合沙箱
- [[多Agent协调|多 Agent 协作]] — Manager-Worker 模式
