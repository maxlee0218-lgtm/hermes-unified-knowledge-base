# Wiki Log

> 按时间顺序记录的所有 wiki 操作。仅附加。
> 格式：`## [YYYY-MM-DD] action | subject`
> 操作：ingest, update, query, lint, create, archive, delete
> 当文件超过 500 条记录时，旋转：重命名为 log-YYYY.md，开始新文件。

## [2026-05-05] create | Wiki 初始化
- 领域：基础设施管理、证照系统运维、AI 工具链与自动化
- 结构已创建：SCHEMA.md, index.md, log.md
- 目录结构：raw/, entities/, concepts/, comparisons/, queries/
- Git 已初始化，等待 GitHub 远程仓库配置

## [2026-05-05] setup | GitHub 连接配置
- 创建私有仓库：maxlee0218-lgtm/obnote
- 配置 GITHUB_TOKEN 和 WIKI_PATH 环境变量
- 推送初始化内容到 GitHub main 分支
- Wiki 已就绪，可开始同步使用

## [2026-05-05] ingest | 数仓重构项目整理
- 连接 Windows PC (LEE) via SSH 反向隧道 (127.0.0.1:2222)
- 扫描 D:\data-warehouse 项目结构
- 统计：约 25GB，主要为 dbt-duckdb (21.9GB)
- 整理关键信息：目录结构、虚拟环境、数据模型、关键脚本、数据库文件
- 创建 wiki 页面：entities/data-warehouse-project.md
- 更新 index.md 和 log.md