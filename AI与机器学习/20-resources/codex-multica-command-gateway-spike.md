# Codex 试验：Multica Command Gateway 接入文档

> 创建时间：2026-05-10  
> 目标：让 Codex 试验用 Multica CLI 建立一个可审计的 Command Gateway，使 ChatGPT 可通过 GitHub 写命令文件，由 Runtime首脑/Codex 代理执行 Multica CLI。  
> 阶段：SPIKE / DRY-RUN 优先  
> 禁止：生产变更、自动验收、自动关闭、自动归档、自动 retry、删除文件、写入密钥。

---

## 001 背景判断

当前 ChatGPT 侧没有可直接调用的 Multica API/connector，因此不能直接创建 Multica Issue。

当前可行链路：

```text
ChatGPT
→ GitHub command file
→ Runtime首脑 / Codex 读取 command file
→ 调用 multica CLI
→ Multica Issue / Autopilot / Agent
→ 结果写回 GitHub
```

Multica 的工作模型本身支持：issue 分配给 agent、评论触发、聊天触发、Autopilot 定时触发；每次触发会产生 task，由本地 daemon 领取执行。

---

## 002 参考依据

- Multica 文档说明：Agent 不在 Multica 服务器执行，当前主要运行模型是本地 daemon，并可驱动本机 AI coding tools。
- Multica 任务模型说明：issue 分配、评论 @、聊天、Autopilot 都会产生执行 task；issue 与 task 是两层对象。
- Multica CLI 文档说明：支持 `multica issue create`、`multica issue update`、`multica issue list`、`multica autopilot list/get/create/update/delete` 等命令。

---

## 003 目标架构

```text
GitHub / llm-wiki
  runtime-commands/pending/*.yaml
  runtime-commands/done/*.json
  runtime-commands/failed/*.json

Runtime首脑 / Codex
  读取 pending 命令
  校验 forbidden_actions
  调用 multica CLI
  写回 done/failed
  更新 runtime-governor-report.md

Multica
  Issue / Task / Agent / Autopilot
```

---

## 004 目录结构

请在仓库或 `/root/wiki` 下建立：

```text
runtime-commands/
  pending/
  running/
  done/
  failed/
  README.md
```

如果建在 GitHub 仓库中，对应路径：

```text
runtime-commands/pending/
runtime-commands/running/
runtime-commands/done/
runtime-commands/failed/
```

---

## 005 命令文件格式

示例：

```yaml
command_id: CMD-20260510-001
type: create_issue
mode: dry_run
workspace: default
title: Kimi Claw Windows 接入 Multica 握手验证
assignee: Kimi Claw Windows Worker
labels:
  - runtime
  - windows
  - dry-run
body: |
  目标：验证 Kimi Claw 是否能作为 Windows 本地只读 Worker 接入 Multica Runtime。

  严格禁止：
  - 不修改生产数据库
  - 不修改 DolphinScheduler
  - 不修改 DataX
  - 不删除文件
  - 不读取或写入密钥原文

  输出：
  - D:\AIWorker\reports\kimi_claw_multica_handshake.md
  - /root/wiki/20-resources/kimi-claw-windows-worker-handshake.md
forbidden_actions:
  - modify_production_db
  - modify_dolphin
  - modify_datax
  - delete_files
  - force_push
  - expose_secrets
acceptance:
  - issue_created_or_dryrun_rendered
  - no_production_change
  - result_written_to_done_or_failed
```

---

## 006 Codex 试验任务

### 任务名称

```text
SPIKE：建立 Multica Command Gateway 最小原型
```

### 任务目标

实现一个最小脚本：

```text
/root/wiki/runtime-commands/process_runtime_command.py
```

或：

```text
scripts/process_runtime_command.py
```

脚本职责：

1. 扫描 `runtime-commands/pending/*.yaml`；
2. 校验 `mode` 必须是 `dry_run` 或 `approved`；
3. 校验 forbidden actions；
4. 对 `type=create_issue` 生成 multica CLI 命令；
5. DRY-RUN 时只打印命令，不执行；
6. approved 时才执行 `multica issue create`；
7. 将结果写入 `runtime-commands/done/*.json` 或 `runtime-commands/failed/*.json`；
8. 不删除原文件，只移动或复制到 running/done/failed；
9. 不处理生产动作。

---

## 007 建议 CLI 适配

先让 Codex 在目标机器上探测真实 CLI：

```bash
multica --help
multica issue --help
multica issue create --help
multica issue list --help
multica autopilot --help
multica autopilot create --help
multica config show
multica workspace get --output json
```

然后再确定 `issue create` 的准确参数。

已知参考形式：

```bash
multica issue create --title "Login bug" --project <project-id>
multica issue list --project <project-id>
multica autopilot list --status active --output json
multica autopilot get <id> --output json
multica autopilot create --title "Nightly bug triage" --description "Scan todo issues and prioritize." --agent "Lambda" --mode create_issue
```

注意：不同版本 CLI 参数可能不完全一致，必须以 `--help` 为准。

---

## 008 最小 Python 伪代码

```python
from pathlib import Path
import json
import subprocess
import time
import yaml

ROOT = Path('/root/wiki/runtime-commands')
PENDING = ROOT / 'pending'
DONE = ROOT / 'done'
FAILED = ROOT / 'failed'
RUNNING = ROOT / 'running'

FORBIDDEN_TYPES = {
    'modify_production_db',
    'modify_dolphin',
    'modify_datax',
    'delete_files',
    'force_push',
    'expose_secrets',
}

def run(cmd):
    return subprocess.run(cmd, shell=True, text=True, capture_output=True, timeout=120)

def process(path: Path):
    data = yaml.safe_load(path.read_text(encoding='utf-8'))
    command_id = data['command_id']
    mode = data.get('mode', 'dry_run')
    ctype = data['type']

    forbidden = set(data.get('forbidden_actions') or [])
    if forbidden & FORBIDDEN_TYPES:
        # forbidden list records boundaries; not an error by itself
        pass

    if ctype != 'create_issue':
        raise ValueError(f'unsupported command type: {ctype}')

    title = data['title'].replace('"', '\\"')
    body = data.get('body', '').replace('"', '\\"')
    assignee = data.get('assignee')

    # Exact flags must be adjusted after checking `multica issue create --help`.
    cmd = f'multica issue create --title "{title}" --body "{body}"'
    if assignee:
        cmd += f' --assignee "{assignee}"'

    result = {
        'command_id': command_id,
        'mode': mode,
        'type': ctype,
        'cmd': cmd,
        'ts': time.strftime('%Y-%m-%d %H:%M:%S'),
    }

    if mode == 'dry_run':
        result['status'] = 'dry_run_rendered'
    elif mode == 'approved':
        cp = run(cmd)
        result['returncode'] = cp.returncode
        result['stdout'] = cp.stdout[-4000:]
        result['stderr'] = cp.stderr[-4000:]
        result['status'] = 'done' if cp.returncode == 0 else 'failed'
    else:
        raise ValueError(f'invalid mode: {mode}')

    outdir = DONE if result['status'] in ('done', 'dry_run_rendered') else FAILED
    outdir.mkdir(parents=True, exist_ok=True)
    (outdir / f'{command_id}.json').write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding='utf-8')

for p in sorted(PENDING.glob('*.yaml')):
    try:
        process(p)
    except Exception as e:
        FAILED.mkdir(parents=True, exist_ok=True)
        (FAILED / f'{p.stem}.json').write_text(json.dumps({'error': str(e)}, ensure_ascii=False, indent=2), encoding='utf-8')
```

---

## 009 安全规则

Codex 必须遵守：

- 默认 `dry_run`；
- 只有 `mode=approved` 才能真实创建 Multica issue；
- 不支持生产变更类型命令；
- 不执行 shell 任意命令；
- 不打印密钥、token、连接串；
- 不删除原始命令文件；
- 每次执行都写 done/failed 结果；
- 每次变更提交 Git。

---

## 010 验收标准

第一阶段只验收 DRY-RUN：

1. 能读取 pending 命令；
2. 能渲染 multica issue create 命令；
3. 不真实创建 issue；
4. 能写 done JSON；
5. 能识别 unsupported command；
6. 能保留审计记录；
7. 不修改生产；
8. 不泄露密钥。

第二阶段再允许 approved：

1. 人工把某个命令改为 `mode=approved`；
2. 脚本真实执行 `multica issue create`；
3. 写回 issue id / url；
4. Runtime首脑 在下一轮巡检中识别该新 issue。

---

## 011 给 Codex 的直接任务

```text
请实现 Multica Command Gateway 最小原型。

要求：
1. 新建 runtime-commands/pending、running、done、failed 目录；
2. 新建 process_runtime_command.py；
3. 支持 create_issue 类型；
4. 默认 dry_run，只渲染 multica CLI 命令；
5. 先执行 multica issue create --help，确认真实参数；
6. 禁止生产变更；
7. 写入 done/failed JSON；
8. 提交 Git；
9. 输出报告：/root/wiki/20-resources/multica-command-gateway-spike-report.md。
```
