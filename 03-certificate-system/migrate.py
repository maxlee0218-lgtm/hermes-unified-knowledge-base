#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
证书系统迁移工具
从 MySQL 导出数据 → 导入到 SQLite

用法:
  1. 先在原 MySQL 服务器上导出数据
  2. 运行此脚本导入到 SQLite

注意: 此脚本需要 pymysql 来连接原 MySQL 数据库
安装: pip install pymysql
"""

import os
import sys
import json
import sqlite3
from datetime import datetime

# 配置
MYSQL_CONFIG = {
    'host': '8.163.49.184',
    'port': 3306,
    'user': 'root',
    'password': 'Lee0218@',
    'database': 'certificate_db',
    'charset': 'utf8mb4'
}

BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, 'data', 'certificates.db')
JSON_EXPORT_FILE = os.path.join(BASE_DIR, 'data', 'mysql_export.json')


def export_from_mysql():
    """从 MySQL 导出数据为 JSON"""
    import pymysql

    print("连接 MySQL...")
    conn = pymysql.connect(**MYSQL_CONFIG)
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    data = {}

    # 导出员工
    cursor.execute('SELECT * FROM employees ORDER BY id')
    data['employees'] = cursor.fetchall()
    print(f"  员工: {len(data['employees'])} 条")

    # 导出证书
    cursor.execute('SELECT * FROM certificates ORDER BY id')
    data['certificates'] = cursor.fetchall()
    print(f"  证书: {len(data['certificates'])} 条")

    # 导出查询日志
    try:
        cursor.execute('SELECT * FROM query_logs ORDER BY id')
        data['query_logs'] = cursor.fetchall()
        print(f"  查询日志: {len(data['query_logs'])} 条")
    except Exception:
        print("  查询日志: 表不存在，跳过")

    # 导出队列
    try:
        cursor.execute('SELECT * FROM query_queue ORDER BY id')
        data['query_queue'] = cursor.fetchall()
        print(f"  队列: {len(data['query_queue'])} 条")
    except Exception:
        print("  队列: 表不存在，跳过")

    cursor.close()
    conn.close()

    # 保存为 JSON
    os.makedirs(os.path.join(BASE_DIR, 'data'), exist_ok=True)
    with open(JSON_EXPORT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, default=str, ensure_ascii=False, indent=2)

    print(f"导出完成: {JSON_EXPORT_FILE}")
    return data


def import_to_sqlite(data):
    """将 JSON 数据导入 SQLite"""
    print(f"\n导入到 SQLite: {DB_PATH}")
    os.makedirs(os.path.join(BASE_DIR, 'data'), exist_ok=True)

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("PRAGMA foreign_keys=ON")

    # 先导入 app 模块来创建表结构
    sys.path.insert(0, BASE_DIR)
    from app import init_db
    init_db()

    # 导入员工
    if data.get('employees'):
        for emp in data['employees']:
            try:
                conn.execute(
                    """INSERT OR IGNORE INTO employees
                       (id, name, id_number, department, phone, position, employment_status, created_at, updated_at)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    (
                        emp.get('id'),
                        emp.get('name', ''),
                        emp.get('id_number', ''),
                        emp.get('department', ''),
                        emp.get('phone', ''),
                        emp.get('position', ''),
                        emp.get('employment_status', '在职'),
                        str(emp.get('created_at', ''))[:19] if emp.get('created_at') else None,
                        str(emp.get('updated_at', ''))[:19] if emp.get('updated_at') else None
                    )
                )
            except Exception as e:
                print(f"  跳过员工 {emp.get('name')}: {e}")
        print(f"  员工: 已导入")

    # 导入证书
    if data.get('certificates'):
        for cert in data['certificates']:
            try:
                conn.execute(
                    """INSERT OR IGNORE INTO certificates
                       (id, employee_id, cert_name, certificate_type, operation_item, issuing_authority,
                        issue_date, expiry_date, review_date, actual_review_date, status, created_at, updated_at)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    (
                        cert.get('id'),
                        cert.get('employee_id'),
                        cert.get('cert_name', ''),
                        cert.get('certificate_type', ''),
                        cert.get('operation_item', ''),
                        cert.get('issuing_authority', ''),
                        str(cert.get('issue_date', ''))[:10] if cert.get('issue_date') else None,
                        str(cert.get('expiry_date', ''))[:10] if cert.get('expiry_date') else None,
                        str(cert.get('review_date', ''))[:10] if cert.get('review_date') else None,
                        str(cert.get('actual_review_date', ''))[:10] if cert.get('actual_review_date') else None,
                        cert.get('status', '有效'),
                        str(cert.get('created_at', ''))[:19] if cert.get('created_at') else None,
                        str(cert.get('updated_at', ''))[:19] if cert.get('updated_at') else None
                    )
                )
            except Exception as e:
                print(f"  跳过证书 ID={cert.get('id')}: {e}")
        print(f"  证书: 已导入")

    # 导入查询日志
    if data.get('query_logs'):
        for log in data['query_logs']:
            try:
                conn.execute(
                    """INSERT INTO query_logs (employee_id, name, id_card, query_type, query_source, result_count, has_new_data, query_status, queried_at)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    (
                        log.get('employee_id'),
                        log.get('name', ''),
                        log.get('id_card', ''),
                        log.get('query_type', ''),
                        log.get('query_source', '手动'),
                        log.get('result_count', 0),
                        log.get('has_new_data', 0),
                        log.get('query_status', '成功'),
                        str(log.get('queried_at', ''))[:19] if log.get('queried_at') else None
                    )
                )
            except Exception as e:
                print(f"  跳过日志: {e}")
        print(f"  查询日志: 已导入")

    # 导入队列
    if data.get('query_queue'):
        for task in data['query_queue']:
            try:
                conn.execute(
                    """INSERT OR IGNORE INTO query_queue (employee_code, name, id_card, query_type, priority, status, result_count, new_cert_count, error_message, duration_seconds, created_at, completed_at)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    (
                        task.get('employee_code', ''),
                        task.get('name', ''),
                        task.get('id_card', ''),
                        task.get('query_type', '全部'),
                        task.get('priority', 5),
                        task.get('status', '待处理'),
                        task.get('result_count', 0),
                        task.get('new_cert_count', 0),
                        task.get('error_message'),
                        task.get('duration_seconds'),
                        str(task.get('created_at', ''))[:19] if task.get('created_at') else None,
                        str(task.get('completed_at', ''))[:19] if task.get('completed_at') else None
                    )
                )
            except Exception as e:
                print(f"  跳过队列任务: {e}")
        print(f"  队列: 已导入")

    conn.commit()
    conn.close()
    print(f"\n导入完成!")


def main():
    print("=" * 50)
    print("证书系统数据迁移工具")
    print("=" * 50)

    mode = input("\n选择模式:\n  1. 从 MySQL 导出并导入 SQLite (完整迁移)\n  2. 从 JSON 文件导入 SQLite (已有导出文件)\n  3. 仅初始化空 SQLite 数据库\n\n请输入 [1/2/3]: ").strip()

    if mode == '1':
        try:
            import pymysql
        except ImportError:
            print("错误: 需要安装 pymysql (pip install pymysql)")
            sys.exit(1)
        data = export_from_mysql()
        import_to_sqlite(data)

    elif mode == '2':
        if not os.path.exists(JSON_EXPORT_FILE):
            print(f"错误: 导出文件不存在: {JSON_EXPORT_FILE}")
            sys.exit(1)
        with open(JSON_EXPORT_FILE, 'r', encoding='utf-8') as f:
            data = json.load(f)
        import_to_sqlite(data)

    elif mode == '3':
        sys.path.insert(0, BASE_DIR)
        from app import init_db
        init_db()
        print("空数据库已初始化")

    else:
        print("无效选择")
        sys.exit(1)

    print("\n迁移完成！可以启动服务: gunicorn -w 2 -b 0.0.0.0:5000 app:app")


if __name__ == '__main__':
    main()
