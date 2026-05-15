"""查询队列服务。"""

from db import db_connection
from repositories import query_queue_repository


def get_queue_page_data(filter_status=''):
    with db_connection() as conn:
        return {
            'counts': query_queue_repository.get_queue_counts(conn),
            'tasks': query_queue_repository.list_queue_tasks(conn, filter_status=filter_status),
            'statistics': query_queue_repository.get_queue_statistics(conn),
            'filter_status': filter_status,
        }


def add_queue_tasks(employees_text, query_type='全部', priority=5):
    added = 0
    duplicate = 0
    not_found = 0

    with db_connection() as conn:
        for line in employees_text.strip().split('\n'):
            line = line.strip()
            if not line:
                continue
            input_val = line.split()[0] if line.split() else ''
            employee = query_queue_repository.find_employee_for_queue(conn, input_val)

            if employee and employee['id_number']:
                if query_queue_repository.has_pending_queue_task(conn, employee['employee_code']):
                    duplicate += 1
                    continue
                query_queue_repository.create_queue_task(
                    conn,
                    employee['employee_code'],
                    employee['employee_name'],
                    employee['id_number'],
                    query_type,
                    priority,
                )
                added += 1
            else:
                not_found += 1

    return {'added': added, 'duplicate': duplicate, 'not_found': not_found}


def clear_finished_queue_tasks():
    with db_connection() as conn:
        return query_queue_repository.clear_finished_queue_tasks(conn)


def get_pending_queue_count():
    with db_connection() as conn:
        return query_queue_repository.get_pending_queue_count(conn)


def get_queue_stats():
    with db_connection() as conn:
        return query_queue_repository.get_queue_counts(conn)
