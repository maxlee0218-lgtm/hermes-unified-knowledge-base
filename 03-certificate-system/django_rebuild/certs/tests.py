from datetime import timedelta
from unittest.mock import patch

from django.contrib.auth import get_user_model
from django.test import Client, TestCase
from django.urls import reverse
from django.utils import timezone

from .jobs import enqueue_query_task
from .models import Certificate, Employee, Notification, QueryExecution, QueryTask
from .services import build_dashboard_context


class BaseSetupMixin:
    def setUp(self):
        self.client = Client()
        self.user = get_user_model().objects.create_superuser(
            username="admin",
            email="admin@example.com",
            password="pass123456",
        )
        self.employee = Employee.objects.create(
            name="张三",
            id_number="320101199001010001",
            department="测试部",
            phone="13800138000",
        )
        self.certificate = Certificate.objects.create(
            employee=self.employee,
            certificate_type="低压电工证",
            operation_item="电工作业",
            expiry_date=timezone.localdate() + timedelta(days=15),
        )
        self.notification = Notification.objects.create(title="提醒", content="新的通知")
        self.task = QueryTask.objects.create(employee=self.employee)


class CertificateModelTests(BaseSetupMixin, TestCase):
    def test_certificate_display_status_warns_before_expiry(self):
        self.assertEqual(self.certificate.display_status, "即将到期")

    def test_certificate_status_refreshes_to_expired(self):
        cert = Certificate.objects.create(
            employee=self.employee,
            certificate_type="焊工证",
            expiry_date=timezone.localdate() - timedelta(days=1),
        )
        self.assertEqual(cert.status, Certificate.Status.EXPIRED)


class PageTests(BaseSetupMixin, TestCase):
    def test_health_endpoint(self):
        response = self.client.get("/health/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "healthy")

    def test_dashboard_page(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "证书管理平台")
        self.assertContains(response, self.employee.name)

    def test_employees_page(self):
        response = self.client.get("/employees")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.employee.name)

    def test_employee_detail_page(self):
        response = self.client.get(f"/employee/{self.employee.id}")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.employee.id_number)

    def test_certificates_page(self):
        response = self.client.get("/certificates")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.certificate.certificate_type)

    def test_expiring_page(self):
        response = self.client.get("/expiring")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.certificate.certificate_type)

    def test_logs_page(self):
        QueryExecution.objects.create(task=self.task, query_source="manual", note="测试日志")
        response = self.client.get("/logs")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "测试日志")

    def test_search_page(self):
        response = self.client.get("/search", {"type": "name", "keyword": "张三"})
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.employee.name)

    def test_queue_page(self):
        response = self.client.get("/queue")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, self.employee.name)

    def test_queue_process_page(self):
        response = self.client.get("/queue/process")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "当前待处理任务")

    def test_admin_login_page(self):
        response = self.client.get("/admin/login/")
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, "Django")


class ApiTests(BaseSetupMixin, TestCase):
    def test_dashboard_api(self):
        response = self.client.get("/api/dashboard/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["employee_count"], 1)

    def test_notifications_api_and_mark_read(self):
        response = self.client.get("/api/notifications")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()["notifications"]), 1)
        mark = self.client.post("/api/notifications/read")
        self.assertEqual(mark.status_code, 200)
        self.notification.refresh_from_db()
        self.assertTrue(self.notification.is_read)

    def test_employee_api_crud(self):
        create = self.client.post(
            "/api/employees",
            data={"name": "李四", "id_number": "320101199001010002", "department": "生产部", "phone": "13900000000"},
            content_type="application/json",
        )
        self.assertEqual(create.status_code, 200)
        employee_id = create.json()["employee_id"]
        detail = self.client.get(f"/api/employees/{employee_id}")
        self.assertEqual(detail.status_code, 200)
        update = self.client.put(
            f"/api/employees/{employee_id}",
            data='{"name":"李四改","id_number":"320101199001010002","department":"生产部","phone":"13900000000"}',
            content_type="application/json",
        )
        self.assertEqual(update.status_code, 200)
        delete = self.client.delete(f"/api/employees/{employee_id}")
        self.assertEqual(delete.status_code, 200)

    def test_employee_list_and_search_api(self):
        response = self.client.get("/api/employees/list")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()), 1)
        search = self.client.get("/api/employees/search", {"keyword": "张三"})
        self.assertEqual(search.status_code, 200)
        self.assertEqual(len(search.json()), 1)

    def test_certificate_api_crud(self):
        create = self.client.post(
            "/api/certificates",
            data={
                "employee_id": self.employee.id,
                "certificate_type": "焊工证",
                "operation_item": "焊接",
                "expiry_date": (timezone.localdate() + timedelta(days=90)).isoformat(),
            },
            content_type="application/json",
        )
        self.assertEqual(create.status_code, 200)
        cert_id = create.json()["certificate_id"]
        detail = self.client.get(f"/api/certificates/{cert_id}")
        self.assertEqual(detail.status_code, 200)
        update = self.client.put(
            f"/api/certificates/{cert_id}",
            data=json_bytes(
                {
                    "employee_id": self.employee.id,
                    "certificate_type": "焊工证更新",
                    "operation_item": "焊接",
                    "expiry_date": (timezone.localdate() + timedelta(days=120)).isoformat(),
                }
            ),
            content_type="application/json",
        )
        self.assertEqual(update.status_code, 200)
        delete = self.client.delete(f"/api/certificates/{cert_id}")
        self.assertEqual(delete.status_code, 200)

    def test_queue_flow_api(self):
        add = self.client.post("/queue/add", {"employees": self.employee.name, "query_type": "全部", "priority": 5})
        self.assertEqual(add.status_code, 200)
        stats = self.client.get("/api/queue/stats")
        self.assertEqual(stats.status_code, 200)
        trigger = self.client.post("/api/queue/trigger")
        self.assertEqual(trigger.status_code, 200)
        clear = self.client.post("/queue/clear")
        self.assertEqual(clear.status_code, 200)

    def test_export_endpoints(self):
        employees = self.client.get("/export/employees")
        self.assertEqual(employees.status_code, 200)
        self.assertIn("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", employees["Content-Type"])
        certs = self.client.get("/export/certificates")
        self.assertEqual(certs.status_code, 200)
        self.assertIn("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", certs["Content-Type"])


class QueueIntegrationTests(BaseSetupMixin, TestCase):
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


def json_bytes(payload):
    import json

    return json.dumps(payload)
