---
title: SSH隧道替代方案
date: 2026-05-13
tags: [network, polardb, ssh-tunnel, optimization]
status: draft
---

# SSH隧道替代方案

## 当前架构

```
150服务器(150.242.81.21) -> SSH隧道 -> Windows(100.87.225.82) -> PolarDB
```

**问题：**
- 多一跳网络延迟
- SSH隧道不稳定，经常断开
- 每次查询需要重新建立隧道
- Windows SSH服务不稳定

## 推荐方案：150服务器直连PolarDB

### 步骤

1. **把150服务器IP加入PolarDB白名单**
   - IP: `150.242.81.21`
   - 操作：阿里云控制台 -> PolarDB -> 白名单设置

2. **验证连接**
   ```python
   import pymysql
   conn = pymysql.connect(
       host='hwpolardb-m-dev2.rwlb.rds.aliyuncs.com',
       port=5018,
       user='hw_dev_02',
       password='PASSWORD',
       database='da_dw',
       charset='utf8mb4',
       connect_timeout=10
   )
   ```

3. **修改dq_probe.py**
   - 去掉SSH隧道逻辑
   - 直接连接PolarDB

### 优点

- 少一跳，延迟降低50%+
- 连接稳定，不用维护隧道
- 代码简化

### 缺点

- 需要修改PolarDB白名单
- 150服务器IP变动时需要更新

## 备选方案

### 方案B：Windows本地Agent

修复Windows Kimi Runtime，让Agent直接在Windows上执行查询。

**状态：** Kimi CLI不支持ACP协议，需要等官方更新。

### 方案C：PolarDB公网访问

开启PolarDB公网访问端点。

**风险：** 安全风险高，不建议生产环境使用。

### 方案D：持久化SSH隧道

使用autossh保持隧道长期在线。

```bash
# 安装autossh
apt-get install autossh

# 启动持久隧道
autossh -M 0 -N -L 15018:hwpolardb-m-dev2.rwlb.rds.aliyuncs.com:5018 \
  -o "ServerAliveInterval=30" -o "ServerAliveCountMax=3" \
  Lee02@100.87.225.82
```

**缺点：** 仍然多一跳，只是减少了手动重建的次数。

## 决策建议

| 方案 | 延迟 | 稳定性 | 安全性 | 实施难度 | 推荐度 |
|---|---|---|---|---|---|
| A. 150直连 | 低 | 高 | 高 | 中 | ⭐⭐⭐⭐⭐ |
| B. Windows Agent | 低 | 中 | 高 | 高 | ⭐⭐⭐ |
| C. 公网访问 | 低 | 高 | 低 | 低 | ⭐ |
| D. autossh | 中 | 中 | 高 | 低 | ⭐⭐⭐ |

## 下一步

1. 用户确认是否修改PolarDB白名单
2. 如果确认，提供详细的阿里云操作步骤
3. 修改dq_probe.py和相关脚本
