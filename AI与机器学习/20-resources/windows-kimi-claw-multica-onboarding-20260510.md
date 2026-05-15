# Windows Kimi Claw 接入 Multica 方案

> 创建时间：2026-05-10  
> 发起方：ChatGPT  
> 状态：生效  
> 阶段：DRY-RUN 接入 / 只读握手  
> 原则：先登记、摸底、握手、边界确认，不直接执行生产动作。

---

## 一、接入目标

将 Windows 上已有的 Kimi Claw 接入 Multica Runtime 体系，作为 Windows 本地执行/辅助执行节点。

Kimi Claw 不作为主脑，不作为业务方案裁决层，不替代 Runtime首脑。

---

## 二、角色定位

```text
ChatGPT = 用户唯一入口 / 业务方案裁决层
Runtime首脑 = Multica Runtime 状态中枢 / 生命周期治理层
Kimi Claw = Windows 本地执行节点 / 辅助执行节点
数据专家 / 数仓管家 / 深度研究智能体 = 专项执行 Agent
GitHub = 版本化记录 / 知识库
```

---

## 三、Kimi Claw 允许职责

Kimi Claw 可以承担：

- Windows 本地文件摸排；
- Windows C/D 盘资产读取；
- Windows 本地环境检查；
- Windows 上 dbt / Dolphin / 测试数仓 / 速程监控状态检查；
- 只读命令执行；
- 本地报告生成；
- 将结果交给 Runtime首脑；
- 不直接对生产执行修改。

---

## 四、严格禁止

Kimi Claw 禁止：

- 修改生产数据库；
- 修改 PolarDB；
- 修改生产 DolphinScheduler；
- 修改生产 DataX；
- 重跑生产任务；
- 自动上线；
- 自动补数；
- 自动恢复服务；
- 自动 retry；
- 自动删除文件；
- force push；
- 写入或泄露密码/token/连接串/密钥；
- 绕过 Runtime首脑 自行创建/关闭/验收 Multica 任务；
- 绕过 ChatGPT 接受业务方案裁决任务。

---

## 五、接入方式

### 阶段 1：登记

在 Multica 中登记 Kimi Claw 作为 Windows 本地执行节点。

登记信息至少包括：

- 名称：Kimi Claw Windows Worker
- 所属机器：Windows
- 运行路径：待 Kimi Claw 自查
- 可用命令：待 Kimi Claw 自查
- 权限级别：只读 / DRY-RUN
- 是否可写文件：仅允许写报告目录
- 是否可连生产库：否
- 是否可改生产：否

### 阶段 2：握手

Kimi Claw 必须输出握手报告：

```text
D:\AIWorker\reports\kimi_claw_multica_handshake.md
```

报告必须包含：

- 当前用户；
- 当前工作目录；
- Kimi Claw 版本/启动方式；
- Windows 主机名；
- C盘/D盘可读性；
- 是否能访问 D:\AIWorker；
- 是否能访问 D:\data-warehouse；
- 是否能访问 Git；
- 是否能访问 Multica；
- 是否能访问 /root/wiki 或 GitHub 镜像；
- 是否存在密钥/密码风险；
- 当前禁止动作是否生效。

### 阶段 3：只读试跑

只允许执行 Windows 本地只读命令，例如：

- 查看目录；
- 查看服务列表；
- 查看端口；
- 查看进程；
- 查看计划任务；
- 查看环境变量名称但不打印敏感值；
- 查看工具版本。

### 阶段 4：Runtime首脑登记

Runtime首脑 将 Kimi Claw 纳入 Windows Worker 清单，但不授予生产执行权。

---

## 六、首个验证任务

任务名称：

```text
Kimi Claw Windows 接入 Multica 握手验证
```

目标：

```text
验证 Kimi Claw 是否能作为 Windows 本地只读执行节点接入 Multica Runtime。
```

输出：

```text
D:\AIWorker\reports\kimi_claw_multica_handshake.md
/root/wiki/20-resources/kimi-claw-windows-worker-handshake.md
```

---

## 七、验收标准

- Kimi Claw 已在 Multica 中可见；
- 能输出 Windows 本地握手报告；
- 未读取或泄露密钥；
- 未修改生产；
- 未重跑生产任务；
- 未删除文件；
- Runtime首脑 能识别 Kimi Claw 为 Windows Worker；
- ChatGPT 能基于报告判断是否允许进入下一阶段。

---

## 八、当前结论

Kimi Claw 可以接入 Multica，但只能先作为 Windows 本地只读 Worker。

不得直接给生产权限，不得绕过 Runtime首脑，不得绕过 ChatGPT。
