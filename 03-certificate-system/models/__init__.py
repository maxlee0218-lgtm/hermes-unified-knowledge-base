import os
from datetime import date, datetime

from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import inspect, text

db = SQLAlchemy()


class TimestampMixin:
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
    updated_at = db.Column(
        db.DateTime,
        default=datetime.now,
        onupdate=datetime.now,
        nullable=False,
    )


class Employee(TimestampMixin, db.Model):
    __tablename__ = "employees"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    employee_code = db.Column(db.String(32), index=True)
    name = db.Column(db.String(100), nullable=False, index=True)
    id_number = db.Column(db.String(18), unique=True, nullable=False, index=True)
    department = db.Column(db.String(100), default="")
    position = db.Column(db.String(100), default="")
    phone = db.Column(db.String(30), default="")
    employment_status = db.Column(db.String(20), default="在职")

    certificates = db.relationship(
        "Certificate",
        backref="employee",
        lazy=True,
        cascade="all, delete-orphan",
    )
    query_logs = db.relationship("QueryLog", backref="employee", lazy=True)
    query_tasks = db.relationship("QueryQueue", backref="employee", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "employee_code": self.employee_code,
            "name": self.name,
            "id_number": self.id_number,
            "id_card": self.id_number,
            "department": self.department,
            "position": self.position,
            "phone": self.phone,
            "employment_status": self.employment_status,
            "created_at": format_datetime(self.created_at),
            "updated_at": format_datetime(self.updated_at),
            "cert_count": len(self.certificates),
        }


class Certificate(TimestampMixin, db.Model):
    __tablename__ = "certificates"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    employee_id = db.Column(db.Integer, db.ForeignKey("employees.id"), nullable=False, index=True)
    employee_code = db.Column(db.String(32), index=True)

    cert_name = db.Column(db.String(200), default="")
    certificate_type = db.Column(db.String(100), nullable=False, index=True)
    cert_type = db.Column(db.String(50), default="")
    cert_category = db.Column(db.String(200), default="")
    operation_item = db.Column(db.String(200), default="")
    cert_item = db.Column(db.String(200), default="")
    cert_number = db.Column(db.String(100), default="", index=True)

    issuing_authority = db.Column(db.String(200), default="")
    issue_authority = db.Column(db.String(200), default="")
    issue_date = db.Column(db.Date)
    valid_from = db.Column(db.Date)
    expiry_date = db.Column(db.Date, index=True)
    valid_until = db.Column(db.Date, index=True)
    review_date = db.Column(db.Date)
    actual_review_date = db.Column(db.Date)

    status = db.Column(db.String(20), default="有效", index=True)
    raw_data = db.Column(db.Text)

    histories = db.relationship(
        "CertificateHistory",
        backref="certificate",
        lazy=True,
        cascade="all, delete-orphan",
    )
    alerts = db.relationship("ExpiryAlert", backref="certificate", lazy=True)

    @property
    def normalized_type(self):
        return self.certificate_type or self.cert_type or ""

    @property
    def normalized_operation_item(self):
        return self.operation_item or self.cert_item or self.cert_category or ""

    @property
    def normalized_authority(self):
        return self.issuing_authority or self.issue_authority or ""

    @property
    def normalized_expiry(self):
        return self.expiry_date or self.valid_until

    def sync_alias_fields(self):
        if self.employee and self.employee.employee_code and not self.employee_code:
            self.employee_code = self.employee.employee_code
        if not self.certificate_type:
            self.certificate_type = self.cert_type or self.cert_category or "其他证书"
        if not self.cert_type:
            self.cert_type = self.certificate_type
        if not self.operation_item:
            self.operation_item = self.cert_item or self.cert_category or ""
        if not self.cert_item:
            self.cert_item = self.operation_item
        if not self.issuing_authority:
            self.issuing_authority = self.issue_authority or ""
        if not self.issue_authority:
            self.issue_authority = self.issuing_authority or ""
        if self.valid_until and not self.expiry_date:
            self.expiry_date = self.valid_until
        if self.expiry_date and not self.valid_until:
            self.valid_until = self.expiry_date
        if not self.cert_name:
            self.cert_name = self.operation_item or self.certificate_type or ""

    def to_dict(self):
        self.sync_alias_fields()
        return {
            "id": self.id,
            "employee_id": self.employee_id,
            "employee_code": self.employee_code or (self.employee.employee_code if self.employee else None),
            "employee_name": self.employee.name if self.employee else None,
            "employee_id_number": self.employee.id_number if self.employee else None,
            "certificate_type": self.certificate_type,
            "cert_type": self.cert_type,
            "cert_category": self.cert_category,
            "operation_item": self.operation_item,
            "cert_item": self.cert_item,
            "cert_number": self.cert_number,
            "issuing_authority": self.issuing_authority,
            "issue_authority": self.issue_authority,
            "issue_date": format_date(self.issue_date),
            "valid_from": format_date(self.valid_from),
            "expiry_date": format_date(self.expiry_date),
            "valid_until": format_date(self.valid_until),
            "review_date": format_date(self.review_date),
            "actual_review_date": format_date(self.actual_review_date),
            "status": self.status,
            "raw_data": self.raw_data,
            "created_at": format_datetime(self.created_at),
            "updated_at": format_datetime(self.updated_at),
        }


class QueryQueue(db.Model):
    __tablename__ = "query_queue"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    employee_id = db.Column(db.Integer, db.ForeignKey("employees.id"), index=True)
    employee_code = db.Column(db.String(32), index=True)
    name = db.Column(db.String(100), nullable=False)
    id_card = db.Column(db.String(18), nullable=False, index=True)
    query_type = db.Column(db.String(50), default="全部证书")
    priority = db.Column(db.Integer, default=5)
    status = db.Column(db.String(20), default="待处理", index=True)
    result_count = db.Column(db.Integer, default=0)
    new_cert_count = db.Column(db.Integer, default=0)
    error_message = db.Column(db.Text)
    duration_seconds = db.Column(db.Float)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
    started_at = db.Column(db.DateTime)
    processed_at = db.Column(db.DateTime)
    completed_at = db.Column(db.DateTime)

    def to_dict(self):
        return {
            "id": self.id,
            "employee_id": self.employee_id,
            "employee_code": self.employee_code,
            "name": self.name,
            "id_card": self.id_card,
            "id_number": self.id_card,
            "query_type": self.query_type,
            "priority": self.priority,
            "status": self.status,
            "result_count": self.result_count,
            "new_cert_count": self.new_cert_count,
            "error_message": self.error_message,
            "duration_seconds": self.duration_seconds,
            "created_at": format_datetime(self.created_at),
            "started_at": format_datetime(self.started_at),
            "processed_at": format_datetime(self.processed_at),
            "completed_at": format_datetime(self.completed_at),
        }


class QueryLog(db.Model):
    __tablename__ = "query_logs"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    employee_id = db.Column(db.Integer, db.ForeignKey("employees.id"), index=True)
    task_id = db.Column(db.Integer, db.ForeignKey("query_queue.id"), index=True)
    name = db.Column(db.String(100), default="")
    id_card = db.Column(db.String(18), default="", index=True)
    query_type = db.Column(db.String(50), default="")
    query_source = db.Column(db.String(100), default="系统自动查询")
    result_count = db.Column(db.Integer, default=0)
    has_new_data = db.Column(db.Boolean, default=False)
    query_status = db.Column(db.String(20), default="成功")
    message = db.Column(db.Text)
    queried_at = db.Column(db.DateTime, default=datetime.now, nullable=False, index=True)

    task = db.relationship("QueryQueue", backref="logs", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "employee_id": self.employee_id,
            "task_id": self.task_id,
            "name": self.name,
            "id_card": self.id_card,
            "query_type": self.query_type,
            "query_source": self.query_source,
            "result_count": self.result_count,
            "has_new_data": self.has_new_data,
            "query_status": self.query_status,
            "message": self.message,
            "queried_at": format_datetime(self.queried_at),
        }


class CertificateHistory(db.Model):
    __tablename__ = "certificate_history"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    certificate_id = db.Column(db.Integer, db.ForeignKey("certificates.id"), nullable=False, index=True)
    event_type = db.Column(db.String(50), default="update")
    snapshot = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)


class ExpiryAlert(db.Model):
    __tablename__ = "expiry_alerts"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    certificate_id = db.Column(db.Integer, db.ForeignKey("certificates.id"), nullable=False, index=True)
    alert_type = db.Column(db.String(20), default="expiry")
    days_remaining = db.Column(db.Integer)
    status = db.Column(db.String(20), default="open")
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)
    resolved_at = db.Column(db.DateTime)


class SystemConfig(db.Model):
    __tablename__ = "system_config"

    config_key = db.Column(db.String(100), primary_key=True)
    config_value = db.Column(db.Text)
    description = db.Column(db.String(255), default="")
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now, nullable=False)


class UpdateNotification(db.Model):
    __tablename__ = "update_notifications"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    title = db.Column(db.String(200), default="")
    content = db.Column(db.Text, default="")
    notification_type = db.Column(db.String(20), default="info")
    is_read = db.Column(db.Boolean, default=False, index=True)
    created_at = db.Column(db.DateTime, default=datetime.now, nullable=False)


def format_date(value):
    if not value:
        return None
    if isinstance(value, str):
        return value[:10]
    return value.strftime("%Y-%m-%d")


def format_datetime(value):
    if not value:
        return None
    if isinstance(value, str):
        return value[:19]
    return value.strftime("%Y-%m-%d %H:%M:%S")


def ensure_schema(app):
    with app.app_context():
        db.create_all()
        ensure_columns()
        sync_employee_codes_from_ods()
        backfill_denormalized_fields()
        ensure_indexes()
        ensure_views()


def ensure_columns():
    inspector = inspect(db.engine)
    table_columns = {
        table: {col["name"] for col in inspector.get_columns(table)}
        for table in inspector.get_table_names()
    }

    add_column_if_missing(
        table_columns,
        "employees",
        "employee_code",
        "ALTER TABLE employees ADD COLUMN employee_code VARCHAR(32) NULL",
    )
    add_column_if_missing(
        table_columns,
        "employees",
        "phone",
        "ALTER TABLE employees ADD COLUMN phone VARCHAR(30) NULL",
    )
    add_column_if_missing(
        table_columns,
        "employees",
        "employment_status",
        "ALTER TABLE employees ADD COLUMN employment_status VARCHAR(20) NULL DEFAULT '在职'",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "employee_code",
        "ALTER TABLE certificates ADD COLUMN employee_code VARCHAR(32) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "cert_name",
        "ALTER TABLE certificates ADD COLUMN cert_name VARCHAR(200) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "certificate_type",
        "ALTER TABLE certificates ADD COLUMN certificate_type VARCHAR(100) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "cert_type",
        "ALTER TABLE certificates ADD COLUMN cert_type VARCHAR(50) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "cert_category",
        "ALTER TABLE certificates ADD COLUMN cert_category VARCHAR(200) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "operation_item",
        "ALTER TABLE certificates ADD COLUMN operation_item VARCHAR(200) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "cert_item",
        "ALTER TABLE certificates ADD COLUMN cert_item VARCHAR(200) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "cert_number",
        "ALTER TABLE certificates ADD COLUMN cert_number VARCHAR(100) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "issuing_authority",
        "ALTER TABLE certificates ADD COLUMN issuing_authority VARCHAR(200) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "issue_authority",
        "ALTER TABLE certificates ADD COLUMN issue_authority VARCHAR(200) NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "expiry_date",
        "ALTER TABLE certificates ADD COLUMN expiry_date DATE NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "valid_from",
        "ALTER TABLE certificates ADD COLUMN valid_from DATE NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "valid_until",
        "ALTER TABLE certificates ADD COLUMN valid_until DATE NULL",
    )
    add_column_if_missing(
        table_columns,
        "certificates",
        "actual_review_date",
        "ALTER TABLE certificates ADD COLUMN actual_review_date DATE NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "employee_id",
        "ALTER TABLE query_queue ADD COLUMN employee_id INTEGER NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "employee_code",
        "ALTER TABLE query_queue ADD COLUMN employee_code VARCHAR(32) NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "id_card",
        "ALTER TABLE query_queue ADD COLUMN id_card VARCHAR(18) NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "query_type",
        "ALTER TABLE query_queue ADD COLUMN query_type VARCHAR(50) NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "result_count",
        "ALTER TABLE query_queue ADD COLUMN result_count INTEGER NULL DEFAULT 0",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "new_cert_count",
        "ALTER TABLE query_queue ADD COLUMN new_cert_count INTEGER NULL DEFAULT 0",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "duration_seconds",
        "ALTER TABLE query_queue ADD COLUMN duration_seconds FLOAT NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "started_at",
        "ALTER TABLE query_queue ADD COLUMN started_at DATETIME NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_queue",
        "completed_at",
        "ALTER TABLE query_queue ADD COLUMN completed_at DATETIME NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_logs",
        "task_id",
        "ALTER TABLE query_logs ADD COLUMN task_id INTEGER NULL",
    )
    add_column_if_missing(
        table_columns,
        "query_logs",
        "message",
        "ALTER TABLE query_logs ADD COLUMN message TEXT NULL",
    )


def add_column_if_missing(table_columns, table_name, column_name, ddl):
    if table_name not in table_columns:
        return
    if column_name in table_columns[table_name]:
        return
    db.session.execute(text(ddl))
    db.session.commit()


def sync_employee_codes_from_ods():
    inspector = inspect(db.engine)
    if "ods_ihr_t_emp_employee" not in inspector.get_table_names():
        return

    db.session.execute(
        text(
            """
            UPDATE employees
            SET employee_code = (
                SELECT ods.employee_code
                FROM ods_ihr_t_emp_employee ods
                WHERE ods.id_number = employees.id_number
                  AND ods.employee_status <> '02'
                  AND ods.employee_id <> 10000000
                  AND ods.employee_type NOT IN ('04')
                  AND ods.employee_code IS NOT NULL
                  AND ods.employee_code <> ''
                ORDER BY ods.last_update_date DESC, ods.employee_id DESC
                LIMIT 1
            )
            WHERE (employee_code IS NULL OR employee_code = '')
              AND EXISTS (
                SELECT 1
                FROM ods_ihr_t_emp_employee ods
                WHERE ods.id_number = employees.id_number
                  AND ods.employee_status <> '02'
                  AND ods.employee_id <> 10000000
                  AND ods.employee_type NOT IN ('04')
                  AND ods.employee_code IS NOT NULL
                  AND ods.employee_code <> ''
            )
            """
        )
    )
    db.session.commit()


def ensure_indexes():
    # Low-risk indexes that speed up list/search pages.
    statements = [
        "CREATE INDEX IF NOT EXISTS idx_emp_code ON employees (employee_code)",
        "CREATE INDEX IF NOT EXISTS idx_cert_employee_code ON certificates (employee_code)",
        "CREATE INDEX IF NOT EXISTS idx_cert_number ON certificates (cert_number)",
        "CREATE INDEX IF NOT EXISTS idx_cert_type2 ON certificates (cert_type)",
        "CREATE INDEX IF NOT EXISTS idx_cert_valid_until ON certificates (valid_until)",
        "CREATE INDEX IF NOT EXISTS idx_queue_id_card ON query_queue (id_card)",
        "CREATE INDEX IF NOT EXISTS idx_logs_id_card ON query_logs (id_card)",
    ]
    for stmt in statements:
        db.session.execute(text(stmt))
    db.session.commit()


def backfill_denormalized_fields():
    statements = [
        """
        UPDATE certificates
        SET employee_code = (
            SELECT e.employee_code
            FROM employees e
            WHERE e.id = certificates.employee_id
        )
        WHERE (employee_code IS NULL OR employee_code = '')
          AND employee_id IS NOT NULL
        """,
        """
        UPDATE query_queue
        SET employee_code = (
            SELECT e.employee_code
            FROM employees e
            WHERE e.id = query_queue.employee_id
        )
        WHERE (employee_code IS NULL OR employee_code = '')
          AND employee_id IS NOT NULL
        """,
    ]
    for stmt in statements:
        db.session.execute(text(stmt))
    db.session.commit()


def ensure_views():
    dialect = db.engine.url.get_backend_name()
    if dialect == "sqlite":
        days_expr = "CAST(julianday(COALESCE(valid_until, expiry_date)) - julianday('now', 'localtime') AS INTEGER)"
    else:
        days_expr = "DATEDIFF(COALESCE(valid_until, expiry_date), CURDATE())"

    db.session.execute(text("DROP VIEW IF EXISTS v_certificate_overview"))
    db.session.execute(
        text(
            f"""
            CREATE VIEW v_certificate_overview AS
            SELECT
                c.id,
                c.employee_id,
                COALESCE(c.employee_code, e.employee_code) AS employee_code,
                e.name,
                e.id_number,
                e.department,
                e.position,
                e.phone,
                c.certificate_type,
                c.cert_type,
                c.cert_category,
                c.operation_item,
                c.cert_item,
                c.cert_number,
                c.issuing_authority,
                c.issue_authority,
                c.issue_date,
                c.valid_from,
                c.expiry_date,
                c.valid_until,
                c.review_date,
                c.actual_review_date,
                c.status,
                {days_expr} AS days_until_expiry
            FROM certificates c
            JOIN employees e ON e.id = c.employee_id
            """
        )
    )
    db.session.execute(text("DROP VIEW IF EXISTS v_expiring_certificates"))
    db.session.execute(
        text(
            """
            CREATE VIEW v_expiring_certificates AS
            SELECT *
            FROM v_certificate_overview
            WHERE days_until_expiry BETWEEN 0 AND 60
            """
        )
    )
    db.session.commit()
