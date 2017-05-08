resource "aws_ecs_service" "svc" {
  name                               = "tf-svc-${var.task_name}-${var.environment}"
  cluster                            = "${var.cluster_arn}"
  task_definition                    = "${aws_ecs_task_definition.main.arn}"
  desired_count                      = "${var.containers_desired}"
  iam_role                           = "${aws_iam_role.ecs_service.name}"
  deployment_minimum_healthy_percent = "${var.deployment_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.deployment_maximum_percent}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.grp.id}"
    container_name   = "${var.task_name}-${var.environment}"
    container_port   = "${var.container_port}"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end"
  ]

  # We should spread across instances since we scale up or down on resources
  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  # We have found that create_before_destroy breaks teardown.  
  #lifecycle {
  #  create_before_destroy = true
  #}
  
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definition.json")}"

  vars {
    image_tag        = "${var.image_tag}"
    container_name   = "${var.task_name}-${var.environment}"
    cpu_value        = "${var.containers_cpu_unit}"
    memory_soft      = "${var.container_memory_reservation}"
    memory_hard      = "${var.container_memory_hard}"
    container_port   = "${var.container_port}"
    task_environment = "${var.environment}"
    log_group_name   = "${aws_cloudwatch_log_group.svc.name}"
    log_group_region = "${var.log_group_region}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                = "${var.task_name}-${var.environment}"
  container_definitions = "${data.template_file.task_definition.rendered}"
}
