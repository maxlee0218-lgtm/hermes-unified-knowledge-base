"""员工服务。"""

from db import db_connection
from repositories import employee_repository
from services.errors import NotFoundError, ValidationError


def create_employee(data):
    name = str(data.get('name', '')).strip()
    id_number = str(data.get('id_number', '')).strip()
    department = str(data.get('department', '')).strip()
    phone = str(data.get('phone', '')).strip()

    if not name:
        raise ValidationError('姓名为必填项')
    if not id_number:
        raise ValidationError('身份证号为必填项')
    if len(id_number) != 18:
        raise ValidationError('身份证号格式不正确（应为18位）')

    with db_connection() as conn:
        if employee_repository.employee_id_number_exists(conn, id_number):
            raise ValidationError('该身份证号已存在')
        return employee_repository.create_employee(conn, name, id_number, department, phone)


def create_employee_from_form(name, id_card, department='', phone=''):
    return create_employee({
        'name': name,
        'id_number': id_card,
        'department': department,
        'phone': phone,
    })


def get_employee(emp_id):
    with db_connection() as conn:
        employee = employee_repository.get_employee_by_id(conn, emp_id)
    if not employee:
        raise NotFoundError('员工不存在')
    return employee


def list_basic_employees():
    with db_connection() as conn:
        return employee_repository.list_basic_employees(conn)


def search_employees(keyword):
    if len(keyword) < 1:
        return []
    with db_connection() as conn:
        return employee_repository.search_employees(conn, keyword)


def update_employee(emp_id, data):
    name = str(data.get('name', '')).strip()
    id_number = str(data.get('id_number', '')).strip()
    department = str(data.get('department', '')).strip()
    phone = str(data.get('phone', '')).strip()

    if not name or not id_number:
        raise ValidationError('姓名和身份证号为必填项')

    with db_connection() as conn:
        if employee_repository.employee_id_number_exists(conn, id_number, exclude_id=emp_id):
            raise ValidationError('该身份证号已存在')
        employee_repository.update_employee(conn, emp_id, name, id_number, department, phone)


def update_employee_from_form(emp_id, name, id_card, department='', phone=''):
    return update_employee(emp_id, {
        'name': name,
        'id_number': id_card,
        'department': department,
        'phone': phone,
    })


def delete_employee(emp_id):
    with db_connection() as conn:
        employee_repository.delete_employee(conn, emp_id)


def list_employees_for_page(search=''):
    with db_connection() as conn:
        return employee_repository.list_employees_for_page(conn, search=search)


def search_page_results(search_type, keyword):
    employees = None
    suggestions_list = None

    if not keyword:
        return employees, suggestions_list

    with db_connection() as conn:
        results = employee_repository.search_employees_for_page(conn, search_type, keyword)

    if search_type == 'id_card':
        employees = results
    elif len(results) > 1:
        suggestions_list = results
    else:
        employees = results

    return employees, suggestions_list
