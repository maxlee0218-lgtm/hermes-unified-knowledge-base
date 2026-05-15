from flask import Blueprint, request, jsonify
from models import db, QueryQueue, Employee, Certificate
from datetime import datetime
import json

queue_bp = Blueprint('queue', __name__)

@queue_bp.route('/', methods=['GET'])
def get_queue():
    """获取查询队列"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    status = request.args.get('status', '')
    
    query = QueryQueue.query
    
    if status:
        query = query.filter(QueryQueue.status == status)
    
    pagination = query.order_by(QueryQueue.priority.desc(), QueryQueue.created_at.asc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'items': [q.to_dict() for q in pagination.items],
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    })

@queue_bp.route('/', methods=['POST'])
def add_to_queue():
    """添加查询任务到队列"""
    data = request.get_json()
    
    # 检查是否已存在相同的待处理任务
    existing = QueryQueue.query.filter_by(
        id_number=data['id_number'],
        cert_type=data['cert_type'],
        status='pending'
    ).first()
    
    if existing:
        return jsonify({'error': '该查询任务已在队列中'}), 400
    
    task = QueryQueue(
        name=data['name'],
        id_number=data['id_number'],
        cert_type=data['cert_type'],
        priority=data.get('priority', 0)
    )
    
    db.session.add(task)
    db.session.commit()
    
    return jsonify(task.to_dict()), 201

@queue_bp.route('/batch', methods=['POST'])
def batch_add_to_queue():
    """批量添加查询任务"""
    data = request.get_json()
    tasks_data = data.get('tasks', [])
    
    created = []
    errors = []
    
    for task_data in tasks_data:
        try:
            # 检查是否已存在
            existing = QueryQueue.query.filter_by(
                id_number=task_data['id_number'],
                cert_type=task_data['cert_type'],
                status='pending'
            ).first()
            
            if existing:
                errors.append(f"{task_data['name']}: 该查询任务已在队列中")
                continue
            
            task = QueryQueue(
                name=task_data['name'],
                id_number=task_data['id_number'],
                cert_type=task_data['cert_type'],
                priority=task_data.get('priority', 0)
            )
            db.session.add(task)
            created.append(task)
        except Exception as e:
            errors.append(f"{task_data.get('name', '未知')}: {str(e)}")
    
    db.session.commit()
    
    return jsonify({
        'created': [t.to_dict() for t in created],
        'created_count': len(created),
        'errors': errors
    })

@queue_bp.route('/<int:id>', methods=['DELETE'])
def delete_queue_task(id):
    """删除队列任务"""
    task = QueryQueue.query.get_or_404(id)
    
    db.session.delete(task)
    db.session.commit()
    
    return jsonify({'message': '删除成功'})

@queue_bp.route('/clear-completed', methods=['POST'])
def clear_completed():
    """清理已完成的任务"""
    tasks = QueryQueue.query.filter(
        QueryQueue.status.in_(['completed', 'failed'])
    ).all()
    
    count = len(tasks)
    for task in tasks:
        db.session.delete(task)
    
    db.session.commit()
    
    return jsonify({'message': f'已清理 {count} 个任务'})

@queue_bp.route('/process', methods=['POST'])
def process_queue():
    """立即处理队列"""
    from services.query_service import QueryService
    
    limit = request.json.get('limit', 10) if request.json else 10
    
    service = QueryService()
    results = service.process_queue(limit=limit)
    
    return jsonify({
        'message': '队列处理完成',
        'results': results
    })

@queue_bp.route('/process-one', methods=['POST'])
def process_one():
    """处理单个任务"""
    data = request.get_json()
    id_number = data.get('id_number')
    cert_type = data.get('cert_type')
    name = data.get('name')
    
    if not id_number or not cert_type:
        return jsonify({'error': '缺少必要参数'}), 400
    
    from services.query_service import QueryService
    
    service = QueryService()
    result = service.query_certificate(id_number, cert_type, name)
    
    return jsonify(result)

@queue_bp.route('/stats', methods=['GET'])
def get_queue_stats():
    """获取队列统计"""
    stats = {
        'pending': QueryQueue.query.filter_by(status='pending').count(),
        'processing': QueryQueue.query.filter_by(status='processing').count(),
        'completed': QueryQueue.query.filter_by(status='completed').count(),
        'failed': QueryQueue.query.filter_by(status='failed').count()
    }
    
    return jsonify(stats)
