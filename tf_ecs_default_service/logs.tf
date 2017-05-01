#create log group for default container
resource "aws_cloudwatch_log_group" "svc" {
  name              = "app-${var.task_name}-${var.environment}"
  retention_in_days = 7
}
