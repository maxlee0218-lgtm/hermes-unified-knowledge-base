from datetime import timedelta

from django.db import transaction
from django.utils import timezone

from .models import Certificate, Employee, Notification, QueryExecution, QueryTask


def build_dashboard_context():
    today = timezone.localdate()
    certificate_qs = Certificate.objects.select_related("employee")
    return {
        "employee_count": Employee.objects.count(),
        "certificate_count": certificate_qs.count(),
        "valid_count": certificate_qs.filter(status=Certificate.Status.VALID).count(),
        "expiring_count": certificate_qs.filter(
            status=Certificate.Status.VALID,
            expiry_date__isnull=False,
            expiry_date__gt=today,
            expiry_date__lte=today + timedelta(days=30),
        ).count(),
        "expired_count": certificate_qs.filter(status=Certificate.Status.EXPIRED).count(),
        "pending_task_count": QueryTask.objects.filter(status=QueryTask.Status.PENDING).count(),
        "running_task_count": QueryTask.objects.filter(status=QueryTask.Status.RUNNING).count(),
        "unread_notification_count": Notification.objects.filter(is_read=False).count(),
        "recent_certificates": certificate_qs.order_by("-created_at")[:8],
        "recent_tasks": QueryTask.objects.select_related("employee").order_by("-created_at")[:8],
        "recent_notifications": Notification.objects.order_by("is_read", "-created_at")[:8],
    }


def process_pending_tasks_inline():
    processed = 0
    for task in QueryTask.objects.select_related("employee").filter(status=QueryTask.Status.PENDING):
        with transaction.atomic():
            task.status = QueryTask.Status.EMPTY
            task.result_count = 0
            task.new_cert_count = 0
            task.completed_at = timezone.now()
            task.save(update_fields=["status", "result_count", "new_cert_count", "completed_at", "updated_at"])
            QueryExecution.objects.create(
                task=task,
                query_source="inline",
                status="成功",
                note="当前为内联处理占位逻辑，未接入外部查询源。",
            )
            Notification.objects.create(
                title=f"查询完成: {task.employee.name}",
                content=f"{task.employee.name} 的 {task.query_type} 查询已处理，当前无记录。",
                notification_type=Notification.NotificationType.INFO,
            )
            processed += 1
    return processed
