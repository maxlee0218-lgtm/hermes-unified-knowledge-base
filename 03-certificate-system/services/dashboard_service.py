"""仪表盘与详情页服务。"""

from datetime import date

from db import db_connection
from repositories import dashboard_repository
from services.errors import NotFoundError
from status_rules import auto_update_cert_status, calculate_days_until_expiry, get_status_class


def get_dashboard_data(status_list=None, cert_type_filter='', keyword='', show_all=False):
    status_list = status_list or []
    with db_connection() as conn:
        updated = auto_update_cert_status(conn)
        rows, _ = dashboard_repository.get_dashboard_rows(
            conn,
            keyword=keyword,
            cert_type_filter=cert_type_filter,
            status_list=status_list,
            show_all=show_all,
        )

    seen = set()
    filtered = []
    for row in rows:
        if not row['certificate_id']:
            filtered.append(row)
            continue
        key = (row['employee_id'], row['certificate_type'])
        days = row.get('days_until_expiry')
        is_valid = row['status'] == '有效' and days is not None and days > 0

        if show_all:
            filtered.append(row)
        else:
            if key not in seen:
                filtered.append(row)
                seen.add(key)
            elif is_valid:
                for i, existing in enumerate(filtered):
                    if (existing['employee_id'], existing['certificate_type']) == key:
                        prev_days = existing.get('days_until_expiry')
                        prev_valid = existing['status'] == '有效' and prev_days is not None and prev_days > 0
                        if not prev_valid:
                            filtered[i] = row
                        break

    valid_map = {}
    for row in filtered:
        if row['certificate_id']:
            key = (row['employee_id'], row['certificate_type'])
            days = row.get('days_until_expiry')
            if row['status'] == '有效' and days is not None and days > 0:
                valid_map[key] = True

    certificates = []
    for row in filtered:
        if row['certificate_id']:
            days = row.get('days_until_expiry')
            key = (row['employee_id'], row['certificate_type'])
            if days is not None and days <= 0:
                if valid_map.get(key):
                    row['display_status'] = '已替换'
                    row['status_class'] = 'status-notice'
                else:
                    row['display_status'] = '已过期'
                    row['status_class'] = 'status-expired'
            else:
                row['display_status'] = row['status']
                row['status_class'] = get_status_class(days, row['status'])
        else:
            row['display_status'] = ''
            row['status_class'] = ''
        certificates.append(row)

    return {
        'certificates': certificates,
        'employee_count': len({r['employee_id'] for r in filtered if r['employee_id']}),
        'certificate_count': len([r for r in filtered if r['certificate_id'] and r.get('display_status') != '已替换']),
        'valid_count': len([r for r in filtered if r['certificate_id'] and r.get('display_status') == '有效']),
        'expired_count': len([r for r in filtered if r['certificate_id'] and r.get('display_status') == '已过期']),
        'warning_count': len([r for r in filtered if r['certificate_id'] and r.get('display_status') == '即将到期']),
        'auto_updated': updated,
    }


def get_unread_notifications():
    with db_connection() as conn:
        return dashboard_repository.get_unread_notifications(conn)


def mark_all_notifications_read():
    with db_connection() as conn:
        return dashboard_repository.mark_all_notifications_read(conn)


def get_employee_detail_data(employee_id):
    with db_connection() as conn:
        employee = dashboard_repository.get_employee_detail(conn, employee_id)
        if not employee:
            raise NotFoundError('员工不存在')
        certificates = dashboard_repository.get_employee_certificates(conn, employee_id)
        query_logs = dashboard_repository.get_employee_query_logs(conn, employee_id)

    employee['id_card'] = employee.get('id_number', '')
    for cert in certificates:
        days = calculate_days_until_expiry(cert['expiry_date'])
        cert['days_until_expiry'] = days
        cert['status_class'] = get_status_class(days, cert['status'])
        cert['initial_issue_date'] = cert.get('issue_date', '')

    return {
        'employee': employee,
        'certificates': certificates,
        'query_logs': query_logs,
        'cert_count': len(certificates),
        'valid_count': sum(1 for c in certificates if c.get('status') == '有效'),
        'expired_count': sum(1 for c in certificates if c.get('status') == '已过期'),
    }


def get_expiring_data(days):
    days = max(1, min(days, 365))
    today = date.today().isoformat()
    with db_connection() as conn:
        certificates = dashboard_repository.get_expiring_certificates(conn, today, days)

    for cert in certificates:
        remaining = calculate_days_until_expiry(cert['expiry_date'])
        cert['days_until_expiry'] = remaining
        cert['status_class'] = get_status_class(remaining, cert['status'])

    return {'certificates': certificates, 'days': days}


def get_recent_logs():
    with db_connection() as conn:
        return dashboard_repository.get_recent_query_logs(conn)
