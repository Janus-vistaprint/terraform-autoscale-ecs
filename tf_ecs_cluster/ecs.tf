## ECS

resource "aws_ecs_cluster" "main" {
  name = "${var.cluster_name}"
}

## CloudWatch Logs

resource "aws_cloudwatch_log_group" "ecs" {
  name = "tf-ecs-${var.cluster_name}/ecs-agent"
}
