/* cpu */
resource "aws_autoscaling_policy" "cpu-over-reserved" {
  name                   = "ECS-${var.cluster_name}-cpu-over-reserved"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu-over-reserved" {
  alarm_name          = "cpu-over-reserved-ECS-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"
  alarm_description   = "This metric monitors ecs cpu reservation, and scales down machines if we have too much cpu avalible"

  alarm_actions = [
    "${aws_autoscaling_policy.cpu-over-reserved.arn}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_autoscaling_policy" "cpu-under-reserved" {
  name                   = "ECS-${var.cluster_name}-cpu-under-reserved"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu-under-reserved" {
  alarm_name          = "cpu-under-reserved-high-ECS-${var.cluster_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "70"
  alarm_description   = "This metric monitors ecs cpu reservation, and scales up machines if we dont have enough cpu avalible"

  alarm_actions = [
    "${aws_autoscaling_policy.cpu-under-reserved.arn}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_autoscaling_policy" "memory-over-reserved" {
  name                   = "ECS-${var.cluster_name}-mem-over-reserved"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

/* memory */
resource "aws_cloudwatch_metric_alarm" "memory-over-reserved" {
  alarm_name          = "memory-over-reserved-ECS-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "20"
  alarm_description   = "This metric monitors ecs memory reservation, and scales down machines if we have too much memory avalible"

  alarm_actions = [
    "${aws_autoscaling_policy.memory-over-reserved.arn}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_autoscaling_policy" "memory-under-reserved" {
  name                   = "ECS-${var.cluster_name}-memory-under-reserved"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory-under-reserved" {
  alarm_name          = "memory-under-reserved-high-ECS-${var.cluster_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "70"
  alarm_description   = "This metric monitors ecs memory reservation, and scales up machines if we dont have enough memory avalible"

  alarm_actions = [
    "${aws_autoscaling_policy.memory-under-reserved.arn}",
  ]

  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}
