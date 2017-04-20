resource "aws_autoscaling_policy" "cpu-scale-up" {
  name                   = "asg-${var.cluster_name}-cpu-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name          = "cpu-util-high-asg-${var.cluster_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "This metric monitors ec2 cpu for high utilization on ECS hosts"

  alarm_actions = [
    "${aws_autoscaling_policy.cpu-scale-up.arn}",
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.app.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_autoscaling_policy" "cpu-scale-down" {
  name                   = "asg-${var.cluster_name}-cpu-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name          = "cpu-util-low-asg-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "3"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"

  # keeping this very low, as we should let ecs reservations to mostly control this
  threshold         = "5"
  alarm_description = "This metric monitors ec2 cpu for low utilization on ECS hosts"

  alarm_actions = [
    "${aws_autoscaling_policy.cpu-scale-down.arn}",
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.app.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_autoscaling_policy" "mem-scale-up" {
  name = "ECS-${var.cluster_name}-mem-scale-up"

  scaling_adjustment = 1

  adjustment_type = "ChangeInCapacity"

  cooldown = 300

  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_autoscaling_policy" "mem-scale-down" {
  name = "ECS-${var.cluster_name}-mem-scale-down"

  scaling_adjustment = -1

  adjustment_type = "ChangeInCapacity"

  cooldown = 300

  autoscaling_group_name = "${aws_autoscaling_group.app.name}"

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory-high" {
  alarm_name = "mem-util-high-asg-${var.cluster_name}"

  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 memory for high utilization on ECS hosts"

  alarm_actions = [
    "${aws_autoscaling_policy.mem-scale-up.arn}",
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.app.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}

resource "aws_cloudwatch_metric_alarm" "memory-low" {
  alarm_name          = "mem-util-low-asg-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"

  # keeping this very low, as we should let ecs reservations to mostly control this
  threshold         = "5"
  alarm_description = "This metric monitors ec2 memory for low utilization on ECS hosts"

  alarm_actions = [
    "${aws_autoscaling_policy.mem-scale-down.arn}",
  ]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.app.name}"
  }

  depends_on = [
    "aws_autoscaling_group.app",
  ]
}
