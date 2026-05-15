---
title: SSH隧道合规替代方案（不开直连）
date: 2026-05-13
tags: [network, polardb, compliance, windows]
status: stable
---

# SSH隧道合规替代方案

## 背景

公司安全规范不允许150服务器直连PolarDB，必须通过Windows作为数据库出口。

## 推荐方案：Windows本地执行

### 方案A：DataGrip + MCP（日常查询）

**架构：**
```
用户 -> DataGrip(Windows) -> PolarDB
```

**配置：**
- DataGrip已安装：D:\DataGrip 2026.1.3
- 数据源已配置：hwpolardb
- MCP已启用

**使用方式：**
1. 打开DataGrip
2. 执行SQL查询
3. 导出结果

**适用场景：**
- 日常数据查询
- 报表开发
- 数据验证

### 方案B：Windows Python脚本（自动化）

**架构：**
```
Windows Python -> pymysql -> PolarDB
```

**安装依赖：**
```bash
pip install pymysql
```

**脚本示例：**
```python
import pymysql

conn = pymysql.connect(
    host='hwpolardb-m-dev2.rwlb.rds.aliyuncs.com',
    port=5018,
    user='hw_dev_02',
    password='PASSWORD',
    database='da_dw',
    charset='utf8mb4'
)

with conn.cursor() as cur:
    cur.execute("SELECT * FROM ads_gx_xs_04_03 WHERE data_date = CURRENT_DATE")
    for row in cur.fetchall():
        print(row)

conn.close()
```

**适用场景：**
- 定时数据同步
- 自动化报表生成
- 数据质量监控

### 方案C：持久化SSH隧道（过渡期）

**架构：**
```
150 -> autossh -> Windows -> PolarDB
```

**安装autossh：**
```bash
# 150服务器
apt-get install autossh
```

**配置systemd服务：**
```ini
# /etc/systemd/system/polardb-tunnel.service
[Unit]
Description=PolarDB SSH Tunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/autossh -M 0 -N \
  -L 15018:hwpolardb-m-dev2.rwlb.rds.aliyuncs.com:5018 \
  -o "ServerAliveInterval=30" \
  -o "ServerAliveCountMax=3" \
  -o "StrictHostKeyChecking=no" \
  Lee02@100.87.225.82
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

**启用服务：**
```bash
systemctl enable polardb-tunnel
systemctl start polardb-tunnel
```

**适用场景：**
- 过渡期使用
- 等待Windows Agent修复

## 方案对比

| 方案 | 合规性 | 效率 | 自动化 | 实施难度 | 推荐度 |
|---|---|---|---|---|---|
| A. DataGrip | ✅ | 中 | ❌ | 低 | ⭐⭐⭐⭐⭐ |
| B. Python脚本 | ✅ | 高 | ✅ | 中 | ⭐⭐⭐⭐⭐ |
| C. autossh隧道 | ✅ | 中 | ✅ | 低 | ⭐⭐⭐ |

## 决策建议

1. **短期**：使用DataGrip手动查询
2. **中期**：部署Windows Python脚本自动化
3. **长期**：等Multica Windows Agent修复

## 下一步

1. 确认Windows Python环境是否可用
2. 如可用，部署自动化脚本
3. 如不可用，先使用DataGrip
