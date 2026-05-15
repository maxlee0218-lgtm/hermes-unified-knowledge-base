import os

from django.conf import settings
from rq import Queue
from rq.connections import Redis

from .models import QueryExecution, QueryTask


def get_queue():
    redis_url = os.environ.get("REDIS_URL", "redis://127.0.0.1:6379/0")
    connection = Redis.from_url(redis_url)
    return Queue(settings.RQ_QUEUE_NAME, connection=connection)


def enqueue_query_task(task_id):
    queue = get_queue()
    job = queue.enqueue("certs.jobs.process_query_task", task_id, job_timeout=300)
    QueryTask.objects.filter(id=task_id).update(enqueued_job_id=job.id, status=QueryTask.Status.PENDING)
    return job.id


def process_query_task(task_id):
    task = QueryTask.objects.select_related("employee").get(id=task_id)
    task.status = QueryTask.Status.RUNNING
    task.save(update_fields=["status", "updated_at"])
    QueryExecution.objects.create(
        task=task,
        query_source="rq-worker",
        status="成功",
        note="占位 worker：这里接入外部证书查询。",
    )
    task.status = QueryTask.Status.EMPTY
    task.result_count = 0
    task.new_cert_count = 0
    task.save(update_fields=["status", "result_count", "new_cert_count", "updated_at"])
