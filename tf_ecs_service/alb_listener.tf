# ALB

resource "aws_alb_target_group" "grp" {
  name                 = "${var.task_name}-${var.environment}"
  port                 = "${var.lb_port}"
  protocol             = "${var.protocol}"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    interval            = "${var.livecheck_interval}"
    path                = "${var.livecheck_path}"
    healthy_threshold   = "${var.livecheck_healthy_threshold}"
    unhealthy_threshold = "${var.livecheck_unhealthy_threshold}"
  }
}

resource "aws_alb_listener" "front_end" {
  count        = "${var.alb_mapping == "/" ?  1 : 0}"
  load_balancer_arn = "${var.lb_id}"
  port              = "${var.lb_port}"
  protocol          = "${var.protocol}"
  ssl_policy        = "${var.ssl_policy}"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.grp.id}"
    type             = "forward"
  }
}

# listener rule
resource "aws_alb_listener_rule" "app" {
 count        = "${var.alb_mapping == "/" ?  0 : 1}"
 listener_arn = "${var.alb_default_listener_arn}"
 priority     = "${var.alb_priority}"

 action = {
   type             = "forward"
   target_group_arn = "${aws_alb_target_group.grp.id}"
 }

 condition {
   field  = "path-pattern"
   values = ["${var.alb_mapping}"]
 }
}
