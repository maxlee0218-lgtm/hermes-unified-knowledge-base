from flask import Blueprint, jsonify
from models import db, Employee, Certificate, QueryQueue
from datetime import datetime, timedelta
from sqlalchemy import func

dashboard_bp = Blueprint('dashboard', __name__)

@dashboard_bp.route('/stats', methods=['GET'])
def get_stats():
    """获取仪表盘统计数据"""
    today = datetime.now().date()
    deadline = today + timedelta(days=30)
    
    # 基础统计
    employee_count = Employee.query.count()
    cert_count = Certificate.query.count()
    
    # 证书状态统计
    valid_count = Certificate.query.filter_by(status='有效').count()
    expired_count = Certificate.query.filter_by(status='过期').count()
    review_count = Certificate.query.filter_by(status='待复审').count()
    
    # 即将到期证书
    expiring_count = Certificate.query.filter(
        Certificate.valid_until <= deadline,
        Certificate.valid_until >= today
    ).count()
    
    # 队列统计
    queue_stats = {
        'pending': QueryQueue.query.filter_by(status='pending').count(),
        'processing': QueryQueue.query.filter_by(status='processing').count(),
        'completed': QueryQueue.query.filter_by(status='completed').count(),
        'failed': QueryQueue.query.filter_by(status='failed').count()
    }
    
    # 证书类型分布
    cert_type_stats = db.session.query(
        Certificate.cert_type,
        func.count(Certificate.id)
    ).group_by(Certificate.cert_type).all()
    
    # 部门证书分布
    dept_stats = db.session.query(
        Employee.department,
        func.count(Certificate.id)
    ).join(Certificate).group_by(Employee.department).all()
    
    return jsonify({
        'employee_count': employee_count,
        'cert_count': cert_count,
        'cert_status': {
            'valid': valid_count,
            'expired': expired_count,
            'review': review_count
        },
        'expiring_count': expiring_count,
        'queue_stats': queue_stats,
        'cert_type_distribution': [{'type': t[0], 'count': t[1]} for t in cert_type_stats],
        'dept_distribution': [{'department': d[0], 'count': d[1]} for d in dept_stats if d[0]]
    })

@dashboard_bp.route('/expiring-list', methods=['GET'])
def get_expiring_list():
    """获取即将到期证书列表"""
    from flask import request
    days = request.args.get('days', 30, type=int)
    limit = request.args.get('limit', 10, type=int)
    
    today = datetime.now().date()
    deadline = today + timedelta(days=days)
    
    certs = Certificate.query.filter(
        Certificate.valid_until <= deadline,
        Certificate.valid_until >= today
    ).order_by(Certificate.valid_until).limit(limit).all()
    
    return jsonify({
        'items': [c.to_dict() for c in certs],
        'total': len(certs)
    })

@dashboard_bp.route('/recent-certs', methods=['GET'])
def get_recent_certs():
    """获取最近添加的证书"""
    from flask import request
    limit = request.args.get('limit', 10, type=int)
    
    certs = Certificate.query.order_by(
        Certificate.created_at.desc()
    ).limit(limit).all()
    
    return jsonify({
        'items': [c.to_dict() for c in certs]
    })

@dashboard_bp.route('/recent-queue', methods=['GET'])
def get_recent_queue():
    """获取最近查询记录"""
    from flask import request
    limit = request.args.get('limit', 10, type=int)
    
    tasks = QueryQueue.query.filter(
        QueryQueue.status.in_(['completed', 'failed'])
    ).order_by(
        QueryQueue.processed_at.desc()
    ).limit(limit).all()
    
    return jsonify({
        'items': [t.to_dict() for t in tasks]
    })
