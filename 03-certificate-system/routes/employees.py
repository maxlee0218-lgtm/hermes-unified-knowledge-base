from flask import Blueprint, request, jsonify
from models import db, Employee, Certificate
from sqlalchemy import or_

employees_bp = Blueprint('employees', __name__)

@employees_bp.route('/', methods=['GET'])
def get_employees():
    """获取员工列表"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    keyword = request.args.get('keyword', '')
    department = request.args.get('department', '')
    
    query = Employee.query
    
    if keyword:
        query = query.filter(
            or_(
                Employee.name.contains(keyword),
                Employee.id_number.contains(keyword)
            )
        )
    
    if department:
        query = query.filter(Employee.department == department)
    
    pagination = query.order_by(Employee.created_at.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'items': [e.to_dict() for e in pagination.items],
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    })

@employees_bp.route('/departments', methods=['GET'])
def get_departments():
    """获取所有部门列表"""
    departments = db.session.query(Employee.department).distinct().all()
    return jsonify([d[0] for d in departments if d[0]])

@employees_bp.route('/<int:id>', methods=['GET'])
def get_employee(id):
    """获取单个员工详情"""
    employee = Employee.query.get_or_404(id)
    data = employee.to_dict()
    data['certificates'] = [c.to_dict() for c in employee.certificates]
    return jsonify(data)

@employees_bp.route('/', methods=['POST'])
def create_employee():
    """添加员工"""
    data = request.get_json()
    
    # 检查身份证号是否已存在
    existing = Employee.query.filter_by(id_number=data['id_number']).first()
    if existing:
        return jsonify({'error': '该身份证号已存在'}), 400
    
    employee = Employee(
        name=data['name'],
        id_number=data['id_number'],
        department=data.get('department', ''),
        position=data.get('position', '')
    )
    
    db.session.add(employee)
    db.session.commit()
    
    return jsonify(employee.to_dict()), 201

@employees_bp.route('/<int:id>', methods=['PUT'])
def update_employee(id):
    """更新员工信息"""
    employee = Employee.query.get_or_404(id)
    data = request.get_json()
    
    # 如果修改身份证号，检查是否冲突
    if 'id_number' in data and data['id_number'] != employee.id_number:
        existing = Employee.query.filter_by(id_number=data['id_number']).first()
        if existing:
            return jsonify({'error': '该身份证号已存在'}), 400
        employee.id_number = data['id_number']
    
    employee.name = data.get('name', employee.name)
    employee.department = data.get('department', employee.department)
    employee.position = data.get('position', employee.position)
    
    db.session.commit()
    
    return jsonify(employee.to_dict())

@employees_bp.route('/<int:id>', methods=['DELETE'])
def delete_employee(id):
    """删除员工（级联删除证书记录）"""
    employee = Employee.query.get_or_404(id)
    
    db.session.delete(employee)
    db.session.commit()
    
    return jsonify({'message': '删除成功'})

@employees_bp.route('/batch', methods=['POST'])
def batch_create_employees():
    """批量添加员工"""
    data = request.get_json()
    employees_data = data.get('employees', [])
    
    created = []
    errors = []
    
    for emp_data in employees_data:
        try:
            existing = Employee.query.filter_by(id_number=emp_data['id_number']).first()
            if existing:
                errors.append(f"{emp_data['name']}: 身份证号已存在")
                continue
            
            employee = Employee(
                name=emp_data['name'],
                id_number=emp_data['id_number'],
                department=emp_data.get('department', ''),
                position=emp_data.get('position', '')
            )
            db.session.add(employee)
            created.append(employee)
        except Exception as e:
            errors.append(f"{emp_data.get('name', '未知')}: {str(e)}")
    
    db.session.commit()
    
    return jsonify({
        'created': [e.to_dict() for e in created],
        'created_count': len(created),
        'errors': errors
    })
