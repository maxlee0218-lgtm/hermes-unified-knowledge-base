# 证件系统

这是一个用于企业内部管理员工证件与官网查询任务的项目，覆盖：

- 员工信息管理
- 证书信息管理
- 查询队列与批量处理
- 特种作业/特种设备官网查询
- 到期预警与查询日志
- 本地部署与运营脚本

当前主运行版本是 Flask 运营版，入口文件为 [operational_app.py](/Users/lijun/Documents/Playground%202/_analysis/certificate-system/operational_app.py)。

## 目录说明

- `operational_app.py`
  当前本地运营主入口
- `models/`
  数据模型、补字段、视图、ODS 工号同步
- `services/`
  查询、队列、业务逻辑
- `templates/`
  Web 页面模板
- `static/`
  静态资源
- `data/`
  本地数据库目录，不纳入 Git
- `django_rebuild/`
  迁移到 Django 的实验版本，保留作参考

## 本地运行

1. 复制 `.env.example` 为 `.env`
2. 安装依赖
3. 启动本地服务

```bash
cd "/Users/lijun/Documents/Playground 2/_analysis/certificate-system"
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
./deploy_local_operational.sh
```

默认本地地址：

- [http://127.0.0.1:8020](http://127.0.0.1:8020)

## 测试

```bash
cd "/Users/lijun/Documents/Playground 2/_analysis/certificate-system"
./.venv/bin/python -m unittest test_operational_app.py
```

## 七天全员刷新

```bash
cd "/Users/lijun/Documents/Playground 2/_analysis/certificate-system"
FULL_REFRESH_CYCLE_DAYS=7 ./.venv/bin/python run_queue_bg.py
```

- `run_queue_bg.py` 会先检查是否到了全员刷新周期
- 到期时会自动为全部在职员工创建“全部证书”更新任务
- 然后继续沿用现有的随机、慢速、分批队列处理策略

## 数据说明

- 本地运行使用 SQLite 兜底数据库
- MariaDB 不可达时会自动切到本地库
- `certificates.employee_code` 会根据员工主档自动回填
- 如果存在 `ods_ihr_t_emp_employee`，系统会按在职范围同步员工工号：
  - `employee_status <> '02'`
  - `employee_id <> 10000000`
  - `employee_type NOT IN ('04')`

## 当前状态

这个仓库保留了项目从需求分析、重构、Django 尝试到 Flask 运营版落地的完整过程，适合作为第一个完整项目长期维护和迭代。
