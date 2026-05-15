"""服务层异常。"""


class ValidationError(Exception):
    """输入校验失败。"""


class NotFoundError(Exception):
    """资源不存在。"""
