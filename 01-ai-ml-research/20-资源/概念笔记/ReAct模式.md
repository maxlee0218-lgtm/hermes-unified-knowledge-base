---
title: "ReAct 循环与手写实现"
created: 2026-05-06
updated: 2026-05-08
stage: connect
type: concept
tags: [ai-ml, implement]
sources: [raw/articles/llm-agent-basics.docx]
status: active
---

<!-- UID: 20260506-react-pattern -->

# ReAct 循环与手写实现

## 原理

ReAct 来自 2022 年 Yao et al. 论文 "ReAct: Synergizing Reasoning and Acting in Language Models"。核心思想：

> 让 LLM 交替进行"思考"和"行动"，每次行动后观察结果，再决定下一步。

每一步都有真实的观察结果来"校准"推理。LLM 不是凭空想象答案，而是基于实际数据一步步推导。

## 格式

```
Thought: <思考过程>
Action: <工具名>(<参数>)
Observation: <工具返回结果>

...

Thought: 我已经得到了答案。
Final Answer: <最终答案>
```

## 纯 Python 实现

```python
import json, re
from litellm import completion

# 1. 定义工具
def calculator(expr: str) -> str:
    import ast, operator
    allowed = {ast.Add: operator.add, ast.Sub: operator.sub,
               ast.Mult: operator.mul, ast.Div: operator.truediv, ast.Pow: operator.pow}
    tree = ast.parse(expr, mode="eval")
    def _eval(node):
        if isinstance(node, ast.Expression): return _eval(node.body)
        if isinstance(node, ast.Constant): return node.value
        if isinstance(node, ast.BinOp): return allowed[type(node.op)](_eval(node.left), _eval(node.right))
        raise ValueError(f"不支持的操作: {ast.dump(node)}")
    return str(_eval(tree))

def weather(city: str) -> str:
    return {"北京": "晴 22°C", "上海": "多云 26°C"}.get(city, "未知城市")

tools = {"calculator": calculator, "weather": weather}

# 2. 设计 System Prompt
SYSTEM_PROMPT = f"""你是一个 ReAct Agent。收到任务后，按以下格式交替输出：
Thought: <你的思考过程>
Action: <工具名>(<参数>)
等待系统返回 Observation 后，继续思考。
当你得出最终答案时，输出：
Thought: 我已经得到了答案。
Final Answer: <最终答案>
可用工具：{"\n".join(f"- {k}: {k}(v)" for k in tools)}
"""

# 3. ReAct 循环
def react_agent(task: str, max_steps: int = 5) -> str:
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT},
        {"role": "user", "content": task},
    ]
    for step in range(max_steps):
        response = completion(model="deepseek/deepseek-chat", messages=messages)
        output = response.choices[0].message.content
        if "Final Answer:" in output:
            return output.split("Final Answer:")[-1].strip()
        action_match = re.search(r"Action:\s*(\w+)\((.+?)\)", output)
        if action_match:
            tool_name, arg = action_match.group(1), action_match.group(2).strip("\"'")
            observation = tools[tool_name](arg) if tool_name in tools else "未知工具"
            messages.append({"role": "assistant", "content": output})
            messages.append({"role": "user", "content": f"Observation: {observation}"})
    return "达到最大步数，未得出答案"
```

## 手写局限性

| 问题 | 原因 | 框架解决方案 |
|------|------|-----------|
| 解析脆弱 | 正则匹配 `Action:tool(arg)` | 结构化输出 + JSON 解析 |
| 没有沙箱 | AST 解析仍有风险 | E2B / Docker 沙箱执行 |
| 错误处理缺失 | 未处理工具调用失败 | 重试机制 + 降级策略 |
| 不支持复杂工具 | 多参数、嵌套调用、异步 | 原生支持 |

## 关键经验

- ReAct 的核心价值在于"观察校准"，每步都有真实数据
- 手写版本能跑，但离生产可用差得远
- 框架封装了模型适配、Prompt 模板、循环控制、工具解析、错误恢复

## 相关

- [[LLM与Agent基础|LLM 和 Agent 基础]] — 源文档
- [[smolagents框架|smolagents 框架入门]] — 工业级实现
- [[Agent架构|Agent 架构模式]] — 单/多 Agent 架构设计
