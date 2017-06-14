resource "aws_appautoscaling_target" "default" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_service.arn}"
  min_capacity       = "${var.containers_min}"
  max_capacity       = "${var.containers_max}"
  depends_on         = ["aws_ecs_service.svc"]
}

resource "aws_appautoscaling_policy" "default-up" {
  name                    = "${var.cluster_name}-${aws_ecs_service.svc.name}-scale-up"
  service_namespace       = "ecs"
  resource_id             = "service/${var.cluster_name}/${aws_ecs_service.svc.name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Average"

  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment          = 1
  }

  depends_on = ["aws_appautoscaling_target.default"]
}

resource "aws_appautoscaling_policy" "default-down" {
  name                    = "${var.cluster_name}-${aws_ecs_service.svc.name}-scale-down"
  service_namespace       = "ecs"
  resource_id             = "service/${var.cluster_name}/${aws_ecs_service.svc.name}"
  scalable_dimension      = "ecs:service:DesiredCount"
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  metric_aggregation_type = "Average"

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }

  depends_on = ["aws_appautoscaling_target.default"]
}

resource "aws_cloudwatch_metric_alarm" "default_service_cpu_high" {
  alarm_name          = "${var.cluster_name}-${aws_ecs_service.svc.name}-cpuutilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "${var.container_cpu_scale_out}"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.svc.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.default-up.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "default_service_cpu_low" {
  alarm_name          = "${var.cluster_name}-${aws_ecs_service.svc.name}-cpuutilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "${var.container_cpu_scale_in}"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.svc.name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.default-down.arn}"]
}
