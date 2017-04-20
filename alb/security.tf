resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${var.vpc_id}"
  name   = "tf-ecs-lbsg-${var.lb_name}"

  ingress {
    protocol    = "tcp"
    from_port   = "${element(var.lb_port, count.index)}"
    to_port     = "${element(var.lb_port, count.index)}"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
