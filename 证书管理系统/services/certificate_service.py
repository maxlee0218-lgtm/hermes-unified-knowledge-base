"""证书服务。"""

from db import db_connection
from repositories import certificate_repository, employee_repository
from services.errors import NotFoundError, ValidationError
from status_rules import calculate_days_until_expiry, validate_date


def _normalize_employee_id(raw_employee_id):
    if raw_employee_id and str(raw_employee_id).isdigit():
        return int(raw_employee_id)
    raise ValidationError('请选择员工')


def _normalize_certificate_payload(data, include_review_date=False):
    employee_id = _normalize_employee_id(data.get('employee_id'))
    certificate_type = str(data.get('certificate_type', '')).strip()
    if not certificate_type:
        raise ValidationError('证书类型为必填项')

    payload = {
        'employee_id': employee_id,
        'certificate_type': certificate_type,
        'operation_item': str(data.get('operation_item', '')).strip(),
        'issuing_authority': str(data.get('issuing_authority', '')).strip(),
        'issue_date': str(data.get('issue_date', '')).strip() or None,
        'expiry_date': str(data.get('expiry_date', '')).strip() or None,
        'status': str(data.get('status', '有效')).strip() or '有效',
    }
    if include_review_date:
        payload['review_date'] = str(data.get('review_date', '')).strip() or None

    date_fields = [('issue_date', payload['issue_date']), ('expiry_date', payload['expiry_date'])]
    if include_review_date:
        date_fields.append(('review_date', payload['review_date']))
    for field_name, field_value in date_fields:
        if field_value and not validate_date(field_value):
            raise ValidationError(f'{field_name} 日期格式不正确')

    return payload


def create_certificate(data, include_review_date=False):
    payload = _normalize_certificate_payload(data, include_review_date=include_review_date)
    with db_connection() as conn:
        if not employee_repository.employee_exists(conn, payload['employee_id']):
            raise ValidationError('员工不存在')
        return certificate_repository.create_certificate(
            conn,
            payload['employee_id'],
            payload['certificate_type'],
            operation_item=payload['operation_item'],
            issuing_authority=payload['issuing_authority'],
            issue_date=payload['issue_date'],
            expiry_date=payload['expiry_date'],
            review_date=payload.get('review_date'),
            status=payload['status'],
        )


def create_certificate_from_form(data):
    return create_certificate(data, include_review_date=False)


def get_certificate(cert_id):
    with db_connection() as conn:
        certificate = certificate_repository.get_certificate_with_employee(conn, cert_id)
    if not certificate:
        raise NotFoundError('证书不存在')
    return certificate


def update_certificate(cert_id, data):
    payload = _normalize_certificate_payload(data, include_review_date=False)
    with db_connection() as conn:
        if not employee_repository.employee_exists(conn, payload['employee_id']):
            raise ValidationError('员工不存在')
        certificate_repository.update_certificate(
            conn,
            cert_id,
            payload['employee_id'],
            payload['certificate_type'],
            operation_item=payload['operation_item'],
            issuing_authority=payload['issuing_authority'],
            issue_date=payload['issue_date'],
            expiry_date=payload['expiry_date'],
            status=payload['status'],
        )


def delete_certificate(cert_id):
    with db_connection() as conn:
        certificate_repository.delete_certificate(conn, cert_id)


def list_certificates_for_page(employee_id=None, search=''):
    with db_connection() as conn:
        certificates = certificate_repository.list_certificates_for_page(
            conn,
            employee_id=employee_id,
            search=search,
        )

    for cert in certificates:
        if cert.get('expiry_date'):
            cert['days_until_expiry'] = calculate_days_until_expiry(cert['expiry_date'])

    return certificates
