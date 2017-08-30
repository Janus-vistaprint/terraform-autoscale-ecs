data "aws_ami" "stable_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ecs-optimized*"]
  }

  owners = ["amazon"]
}
