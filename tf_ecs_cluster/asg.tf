resource "aws_launch_configuration" "app" {
  security_groups = [
    "${aws_security_group.instance_sg.id}",
  ]

  image_id                    = "${data.aws_ami.stable_ecs.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.name}"
  associate_public_ip_address = false
  key_name                    = "${var.key_name}"

  # ec2 optimized instances

  user_data = <<EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main.name} > /etc/ecs/ecs.config
    sudo yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https zip unzip wget perl-Digest-SHA.x86_64 
    cd /home/ec2-user
    wget http://ec2-downloads.s3.amazonaws.com/cloudwatch-samples/CloudWatchMonitoringScripts-v1.1.0.zip
    unzip CloudWatchMonitoringScripts-v1.1.0.zip
    rm CloudWatchMonitoringScripts-v1.1.0.zip
    chown ec2-user:ec2-user aws-scripts-mon
    (crontab -u ec2-user -l 2>/dev/null; echo "*/1 * * * * /home/ec2-user/aws-scripts-mon/mon-put-instance-data.pl --auto-scaling --mem-util --disk-space-util --disk-path=/ --from-cron") | crontab -
    EOF
  #   user_data = "${data.template_file.cloud_config.rendered}"
  lifecycle {
    create_before_destroy = true
  }
  root_block_device {
    volume_size = "${var.asg_disk_size}"
  }
}

### Compute

resource "aws_autoscaling_group" "app" {
  name                 = "tf-${var.cluster_name}"
  vpc_zone_identifier  = ["${var.private_subnets}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.app.name}"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  depends_on           = ["aws_launch_configuration.app"]
  enabled_metrics      = "${var.asg_metrics}"

  /*
       in 0.9.3 deletes are not handled properly when lc, and asg's have create before destroy
         https://github.com/hashicorp/terraform/issues/13517
      lifecycle {
        create_before_destroy = true
      }*/

  tag {
    key                 = "Name"
    value               = "tf-${var.cluster_name}"
    propagate_at_launch = true
  }
}
