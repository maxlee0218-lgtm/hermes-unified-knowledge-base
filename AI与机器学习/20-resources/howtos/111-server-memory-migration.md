# 111服务器记忆迁移记录

## 基础设施拓扑

- **PocketClaw(手机)** → 150.242.81.21 Gateway(kimi-k2.6) → SSH jump到111.229.153.11(跳板机+数仓监控)和阿里云8.x(生产环境)
- **Gateway api_server**: 绑定0.0.0.0:8642，非本地绑定需要API_SERVER_KEY环境变量
- **消息平台**: 飞书(主)、微信

## 数据库连接

- **PolarDB**: hwpolardb-m-dev2.rwlb.rds.aliyuncs.com:5018
- **连接方式**: 通过Windows PC 127.0.0.1:2222跳转
- **账号**: hw_dev_02
- **权限**: 仅SELECT，无INDEX/ALTER/PROCESS/ANALYZE
- **三库**: da_dw(数仓)、da_datax(DataX/XXL-JOB)、da_dolphin(DolphinScheduler)

## 项目状态

- **数仓监控**: 路径/opt/warehouse-monitor-v2/，含Kanban工作流(5列: TODO/IN PROGRESS/BLOCKED/REVIEW/DONE)
- **证照系统**: V2全公司推广中，官网抓取验证中
- **证书系统**: 核心修复沉淀为cert-system-specialist skill
- **监控大屏V2**: 生产(DataX+dbt+PolarDB)+测试(Python+DuckDB+MySQL3406)+证照(Flask+SQLite)

## 安全与规范

- **抗幻觉自律体系V2.0**: 模型主动三轮自校验(追问/反问/质问)，永久强制生效
- **代码变更硬约束**: 修改后必须完成五步验证清单
- **CTF沙箱思维**: 信任运行时行为>源码注释，一次只变一个变量
- **数据库连接**: 默认通过Windows PC中转，不从跳板机直连

## 用户偏好

- **风格**: 简洁直接，结果导向，不喜欢冗长解释
- **授权**: "你自己去搞"=全权执行，不喜欢反复确认细节(除非高风险)
- **前端**: 对假数据极度敏感，任何硬编码mock/fallback必须清除或标记待接入
- **禁忌**: 不接受翻译，不接受筛选多选题式确认(除非高风险)，不明文传输私钥

## 修复记录

- [2026-05-08] 升级v0.10.0→v0.13.0
- [2026-05-08] 修复Kanban数据库迁移错误
- [2026-05-08] 修复Cron定时任务报错
- [2026-05-08] 配置飞书平台
- [2026-05-08] API Key移至.env
- [2026-05-08] 启用session_search
- [2026-05-08] 清理冗余人格配置
- [2026-05-08] 配置日志错误监控定时器
- [2026-05-08] 修复clawpilot hermes CLI路径

## 关键配置

- **venv路径**: /home/ubuntu/.hermes/profiles/infra/hermes-agent/venv/
- **hermes命令**: /usr/local/bin/hermes (wrapper脚本)
- **API Key**: ~/.hermes/.env中KIMI_API_KEY
- **日志**: /var/log/hermes/gateway.log
- **clawpilot日志**: /home/ubuntu/.clawai/clawpilot.log
