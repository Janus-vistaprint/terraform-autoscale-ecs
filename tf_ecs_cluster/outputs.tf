output "instance_security_group" {
  value = "${aws_security_group.instance_sg.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.app.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.app.id}"
}

output "cluster_arn" {
  value = "${aws_ecs_cluster.main.id}"
}

output "cluster_name" {
  value = "${aws_ecs_cluster.main.name}"
}
