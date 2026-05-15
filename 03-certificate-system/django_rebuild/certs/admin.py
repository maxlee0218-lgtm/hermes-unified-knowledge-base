from django.contrib import admin
from django.utils import timezone

from .models import Certificate, Employee, Notification, QueryExecution, QueryTask


class CertificateInline(admin.TabularInline):
    model = Certificate
    extra = 0
    show_change_link = True


@admin.register(Employee)
class EmployeeAdmin(admin.ModelAdmin):
    list_display = ("name", "id_number", "department", "phone", "employment_status", "created_at")
    list_filter = ("department", "employment_status")
    search_fields = ("name", "id_number", "department", "phone")
    inlines = [CertificateInline]


@admin.action(description="刷新选中证书状态")
def refresh_selected_status(modeladmin, request, queryset):
    for cert in queryset:
        cert.refresh_status(today=timezone.localdate())
        cert.save(update_fields=["status", "updated_at"])


@admin.register(Certificate)
class CertificateAdmin(admin.ModelAdmin):
    list_display = (
        "employee",
        "certificate_type",
        "operation_item",
        "expiry_date",
        "status",
        "display_status_value",
        "source_type",
    )
    list_filter = ("status", "source_type", "certificate_type", "employee__department")
    search_fields = ("employee__name", "employee__id_number", "certificate_type", "operation_item", "cert_number")
    autocomplete_fields = ("employee",)
    actions = [refresh_selected_status]

    @admin.display(description="展示状态")
    def display_status_value(self, obj):
        return obj.display_status


class QueryExecutionInline(admin.TabularInline):
    model = QueryExecution
    extra = 0
    readonly_fields = ("created_at",)


@admin.action(description="标记选中任务为待处理")
def requeue_selected_tasks(modeladmin, request, queryset):
    queryset.update(status=QueryTask.Status.PENDING, error_message="", completed_at=None)


@admin.register(QueryTask)
class QueryTaskAdmin(admin.ModelAdmin):
    list_display = ("employee", "query_type", "priority", "status", "result_count", "new_cert_count", "created_at")
    list_filter = ("status", "query_type", "employee__department")
    search_fields = ("employee__name", "employee__id_number")
    autocomplete_fields = ("employee",)
    readonly_fields = ("enqueued_job_id",)
    inlines = [QueryExecutionInline]
    actions = [requeue_selected_tasks]


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ("title", "notification_type", "is_read", "created_at")
    list_filter = ("notification_type", "is_read")
    search_fields = ("title", "content")


@admin.register(QueryExecution)
class QueryExecutionAdmin(admin.ModelAdmin):
    list_display = ("task", "query_source", "status", "has_new_data", "created_at")
    list_filter = ("status", "has_new_data", "query_source")
