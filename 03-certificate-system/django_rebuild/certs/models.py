from django.db import models
from django.utils import timezone


class TimestampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class Employee(TimestampedModel):
    class EmploymentStatus(models.TextChoices):
        ACTIVE = "在职", "在职"
        INACTIVE = "停用", "停用"
        LEFT = "离职", "离职"

    name = models.CharField(max_length=100)
    id_number = models.CharField(max_length=18, unique=True)
    department = models.CharField(max_length=100, blank=True, default="")
    phone = models.CharField(max_length=30, blank=True, default="")
    position = models.CharField(max_length=100, blank=True, default="")
    employment_status = models.CharField(
        max_length=20,
        choices=EmploymentStatus.choices,
        default=EmploymentStatus.ACTIVE,
    )

    class Meta:
        ordering = ["name", "id"]

    def __str__(self):
        return f"{self.name} ({self.id_number})"


class Certificate(TimestampedModel):
    class SourceType(models.TextChoices):
        MANUAL = "manual", "手工录入"
        IMPORT = "import", "外部导入"

    class Status(models.TextChoices):
        VALID = "有效", "有效"
        EXPIRED = "已过期", "已过期"
        PENDING_REVIEW = "待复审", "待复审"
        VOID = "作废", "作废"

    employee = models.ForeignKey(Employee, related_name="certificates", on_delete=models.CASCADE)
    certificate_type = models.CharField(max_length=100)
    operation_item = models.CharField(max_length=100, blank=True, default="")
    cert_number = models.CharField(max_length=100, blank=True, default="")
    issuing_authority = models.CharField(max_length=200, blank=True, default="")
    issue_date = models.DateField(null=True, blank=True)
    expiry_date = models.DateField(null=True, blank=True)
    review_date = models.DateField(null=True, blank=True)
    actual_review_date = models.DateField(null=True, blank=True)
    source_type = models.CharField(max_length=20, choices=SourceType.choices, default=SourceType.MANUAL)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.VALID)
    raw_payload = models.JSONField(default=dict, blank=True)

    class Meta:
        ordering = ["employee__name", "certificate_type", "-expiry_date", "-id"]

    def __str__(self):
        return f"{self.employee.name} - {self.certificate_type}"

    @property
    def days_until_expiry(self):
        if not self.expiry_date:
            return None
        return (self.expiry_date - timezone.localdate()).days

    @property
    def display_status(self):
        if self.status == self.Status.VOID:
            return self.status
        days = self.days_until_expiry
        if days is None:
            return self.status
        if days <= 0:
            return self.Status.EXPIRED
        if days <= 30:
            return "即将到期"
        return self.status

    def refresh_status(self, today=None):
        today = today or timezone.localdate()
        if self.status == self.Status.VOID:
            return self.status
        if self.expiry_date and self.expiry_date <= today:
            self.status = self.Status.EXPIRED
        elif self.review_date and self.review_date <= today:
            self.status = self.Status.PENDING_REVIEW
        else:
            self.status = self.Status.VALID
        return self.status

    def save(self, *args, **kwargs):
        self.refresh_status()
        super().save(*args, **kwargs)


class QueryTask(TimestampedModel):
    class QueryType(models.TextChoices):
        ALL = "全部", "全部"
        SPECIAL_OPERATION = "特种作业", "特种作业"
        SPECIAL_EQUIPMENT = "特种设备", "特种设备"

    class Status(models.TextChoices):
        PENDING = "待处理", "待处理"
        RUNNING = "处理中", "处理中"
        SUCCESS = "已完成", "已完成"
        EMPTY = "无记录", "无记录"
        FAILED = "失败", "失败"
        CANCELED = "已取消", "已取消"

    employee = models.ForeignKey(Employee, related_name="query_tasks", on_delete=models.CASCADE)
    query_type = models.CharField(max_length=20, choices=QueryType.choices, default=QueryType.ALL)
    priority = models.PositiveIntegerField(default=5)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    result_count = models.PositiveIntegerField(default=0)
    new_cert_count = models.PositiveIntegerField(default=0)
    duration_seconds = models.FloatField(null=True, blank=True)
    error_message = models.TextField(blank=True, default="")
    completed_at = models.DateTimeField(null=True, blank=True)
    enqueued_job_id = models.CharField(max_length=64, blank=True, default="")

    class Meta:
        ordering = ["-priority", "-created_at"]

    def __str__(self):
        return f"{self.employee.name} - {self.query_type} - {self.status}"


class QueryExecution(TimestampedModel):
    task = models.ForeignKey(QueryTask, related_name="executions", on_delete=models.CASCADE)
    query_source = models.CharField(max_length=50, blank=True, default="manual")
    result_snapshot = models.JSONField(default=dict, blank=True)
    diff_summary = models.JSONField(default=dict, blank=True)
    has_new_data = models.BooleanField(default=False)
    status = models.CharField(max_length=20, default="成功")
    note = models.TextField(blank=True, default="")

    class Meta:
        ordering = ["-created_at"]


class Notification(TimestampedModel):
    class NotificationType(models.TextChoices):
        INFO = "info", "信息"
        WARNING = "warning", "预警"
        SUCCESS = "success", "成功"
        ERROR = "error", "异常"

    title = models.CharField(max_length=200)
    content = models.TextField()
    notification_type = models.CharField(
        max_length=20,
        choices=NotificationType.choices,
        default=NotificationType.INFO,
    )
    is_read = models.BooleanField(default=False)

    class Meta:
        ordering = ["is_read", "-created_at"]

    def __str__(self):
        return self.title
