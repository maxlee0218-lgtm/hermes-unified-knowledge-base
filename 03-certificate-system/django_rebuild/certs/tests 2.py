from datetime import timedelta
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import Client, TestCase
from django.urls import reverse
from django.utils import timezone

from .jobs import enqueue_query_task
from .models import Certificate, Employee, Notification, QueryTask
from .services import build_dashboard_context


class CertificateModelTests(TestCase):
    def setUp(self):
        self.employee = Employee.objects.create(name="张三", id_number="320101199001010001")

    def test_certificate_status_refreshes_to_expired(self):
        cert = Certificate.objects.create(
            employee=self.employee,
            certificate_type="低压电工证",
            expiry_date=timezone.localdate() - timedelta(days=1),
        )
        self.assertEqual(cert.status, Certificate.Status.EXPIRED)
        self.assertEqual(cert.display_status, Certificate.Status.EXPIRED)

    def test_certificate_display_status_warns_before_expiry(self):
        cert = Certificate.objects.create(
            employee=self.employee,
            certificate_type="焊工证",
            expiry_date=timezone.localdate() + timedelta(days=10),
        )
        self.assertEqual(cert.display_status, "即将到期")


class DashboardTests(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = get_user_model().objects.create_superuser(
            username="admin",
            email="admin@example.com",
            password="pass123456",
        )
        self.employee = Employee.objects.create(name="李四", id_number="320101199001010002")
        Certificate.objects.create(
            employee=self.employee,
            certificate_type="高压电工证",
            expiry_date=timezone.localdate() + timedelta(days=15),
        )
        QueryTask.objects.create(employee=self.employee)
        Notification.objects.create(title="提醒", content="有新的待处理任务")

    def test_health_endpoint(self):
        response = self.client.get(reverse("health"))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "healthy")

    def test_dashboard_requires_login(self):
        response = self.client.get(reverse("dashboard"))
        self.assertEqual(response.status_code, 302)

    def test_dashboard_api_counts(self):
        self.client.force_login(self.user)
        response = self.client.get(reverse("dashboard_api"))
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["employee_count"], 1)
        self.assertEqual(data["certificate_count"], 1)
        self.assertEqual(data["pending_task_count"], 1)
        self.assertEqual(data["unread_notification_count"], 1)


class QueueTests(TestCase):
    def setUp(self):
        self.employee = Employee.objects.create(name="王五", id_number="320101199001010003")
        self.task = QueryTask.objects.create(employee=self.employee)

    def test_dashboard_context(self):
        context = build_dashboard_context()
        self.assertEqual(context["employee_count"], 1)
        self.assertEqual(context["pending_task_count"], 1)

    @patch("certs.jobs.get_queue")
    def test_enqueue_query_task_updates_job_id(self, mocked_get_queue):
        class DummyJob:
            id = "job-123"

        class DummyQueue:
            def enqueue(self, *args, **kwargs):
                return DummyJob()

        mocked_get_queue.return_value = DummyQueue()
        job_id = enqueue_query_task(self.task.id)
        self.task.refresh_from_db()
        self.assertEqual(job_id, "job-123")
        self.assertEqual(self.task.enqueued_job_id, "job-123")
