from flask import Blueprint, request, jsonify
from models import db, Certificate, Employee
from datetime import datetime, timedelta
from sqlalchemy import or_

certificates_bp = Blueprint('certificates', __name__)

def update_certificate_status(cert):
    """更新证书状态"""
    if not cert.valid_until:
        cert.status = '有效'
        return
    
    today = datetime.now().date()
    
    if cert.valid_until < today:
        cert.status = '过期'
    elif cert.review_date and cert.review_date <= today + timedelta(days=30):
        cert.status = '待复审'
    else:
        cert.status = '有效'

@certificates_bp.route('/', methods=['GET'])
def get_certificates():
    """获取证书列表"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    keyword = request.args.get('keyword', '')
    cert_type = request.args.get('cert_type', '')
    status = request.args.get('status', '')
    employee_id = request.args.get('employee_id', type=int)
    
    query = Certificate.query
    
    if keyword:
        query = query.join(Employee).filter(
            or_(
                Employee.name.contains(keyword),
                Certificate.cert_number.contains(keyword),
                Certificate.cert_category.contains(keyword)
            )
        )
    
    if cert_type:
        query = query.filter(Certificate.cert_type == cert_type)
    
    if status:
        query = query.filter(Certificate.status == status)
    
    if employee_id:
        query = query.filter(Certificate.employee_id == employee_id)
    
    pagination = query.order_by(Certificate.created_at.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    # 更新状态
    items = []
    for cert in pagination.items:
        update_certificate_status(cert)
        items.append(cert.to_dict())
    
    db.session.commit()
    
    return jsonify({
        'items': items,
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    })

@certificates_bp.route('/<int:id>', methods=['GET'])
def get_certificate(id):
    """获取单个证书详情"""
    cert = Certificate.query.get_or_404(id)
    update_certificate_status(cert)
    db.session.commit()
    return jsonify(cert.to_dict())

@certificates_bp.route('/', methods=['POST'])
def create_certificate():
    """添加证书"""
    data = request.get_json()
    
    # 检查员工是否存在
    employee = Employee.query.get(data['employee_id'])
    if not employee:
        return jsonify({'error': '员工不存在'}), 404
    
    cert = Certificate(
        employee_id=data['employee_id'],
        cert_type=data['cert_type'],
        cert_category=data.get('cert_category', ''),
        cert_item=data.get('cert_item', ''),
        cert_number=data.get('cert_number', ''),
        issue_authority=data.get('issue_authority', ''),
        issue_date=datetime.strptime(data['issue_date'], '%Y-%m-%d').date() if data.get('issue_date') else None,
        valid_from=datetime.strptime(data['valid_from'], '%Y-%m-%d').date() if data.get('valid_from') else None,
        valid_until=datetime.strptime(data['valid_until'], '%Y-%m-%d').date() if data.get('valid_until') else None,
        review_date=datetime.strptime(data['review_date'], '%Y-%m-%d').date() if data.get('review_date') else None,
        raw_data=data.get('raw_data', '')
    )
    
    update_certificate_status(cert)
    
    db.session.add(cert)
    db.session.commit()
    
    return jsonify(cert.to_dict()), 201

@certificates_bp.route('/<int:id>', methods=['PUT'])
def update_certificate(id):
    """更新证书信息"""
    cert = Certificate.query.get_or_404(id)
    data = request.get_json()
    
    cert.cert_type = data.get('cert_type', cert.cert_type)
    cert.cert_category = data.get('cert_category', cert.cert_category)
    cert.cert_item = data.get('cert_item', cert.cert_item)
    cert.cert_number = data.get('cert_number', cert.cert_number)
    cert.issue_authority = data.get('issue_authority', cert.issue_authority)
    
    if data.get('issue_date'):
        cert.issue_date = datetime.strptime(data['issue_date'], '%Y-%m-%d').date()
    if data.get('valid_from'):
        cert.valid_from = datetime.strptime(data['valid_from'], '%Y-%m-%d').date()
    if data.get('valid_until'):
        cert.valid_until = datetime.strptime(data['valid_until'], '%Y-%m-%d').date()
    if data.get('review_date'):
        cert.review_date = datetime.strptime(data['review_date'], '%Y-%m-%d').date()
    
    update_certificate_status(cert)
    db.session.commit()
    
    return jsonify(cert.to_dict())

@certificates_bp.route('/<int:id>', methods=['DELETE'])
def delete_certificate(id):
    """删除证书"""
    cert = Certificate.query.get_or_404(id)
    
    db.session.delete(cert)
    db.session.commit()
    
    return jsonify({'message': '删除成功'})

@certificates_bp.route('/expiring', methods=['GET'])
def get_expiring_certificates():
    """获取即将到期的证书"""
    days = request.args.get('days', 30, type=int)
    
    today = datetime.now().date()
    deadline = today + timedelta(days=days)
    
    certs = Certificate.query.filter(
        Certificate.valid_until <= deadline,
        Certificate.valid_until >= today
    ).order_by(Certificate.valid_until).all()
    
    return jsonify({
        'items': [c.to_dict() for c in certs],
        'total': len(certs),
        'days': days
    })

@certificates_bp.route('/update-all-status', methods=['POST'])
def update_all_status():
    """更新所有证书状态"""
    certs = Certificate.query.all()
    
    status_count = {'有效': 0, '过期': 0, '待复审': 0}
    
    for cert in certs:
        old_status = cert.status
        update_certificate_status(cert)
        if cert.status != old_status:
            status_count[cert.status] = status_count.get(cert.status, 0) + 1
    
    db.session.commit()
    
    return jsonify({
        'message': '状态更新完成',
        'changes': status_count
    })
