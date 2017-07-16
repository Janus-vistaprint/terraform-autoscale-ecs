## terraform-autoscale-ecs

this is a suite of modules that help you build an autoscaling ecs cluster. This wires up cloudwatch alarms to scale the cluster, and associated containers up and down when required.


example main.tf file:

`terraform apply -var aws_region=${region} -var app_name=${app} -var environment=${environment} -var image_tag=8547322993988.dkr.ecr.eu-west-1.amazonaws.com/myapp:1.0.0`


This would be an example file that uses our modules. This creates an alb, ecs cluster, and registers an ecs service in the cluster with the given docker tag.
```
# This makes a load balancer, no logging
module "alb" {
  source              = "git::https://github.com/Janus-vistaprint/terraform-autoscale-ecs.git//tf_alb"

  # the load balancers name
  lb_name = "${var.app_name}"

  # what ports should the load balancer forward
  lb_port        = [80, 443]
  public_subnets = ["sg-ids"]
  vpc_id         = "YOUR VPC ID"

  ### Optional arguments, to manage route 53"
  route53_dns_name    = "mytestloadbalancer.myworld.com"

  # route53 DNS zone to modify
  route53_dns_zone_id = "/hostedzone/123456"  
}

# example of load balancer with logs being exported to S3
module "alb_log" {
  source  = "git::https://github.com/Janus-vistaprint/terraform-autoscale-ecs.git//tf_alb_logged"

  # name of load balancer
  lb_name  = "${var.app_name}"

  # what ports should the load balancer forward
  lb_port   = [80]
  public_subnets = ["sg_ids"]
  vpc_id    = "YOUR VPC ID"

  ### Optional arguments, to manage route 53"
  route53_dns_name    = "mytestloadbalancer.myworld.com"

  # route53 DNS zone to modify
  route53_dns_zone_id = "/hostedzone/123456"  

  # optional, destroy bucket if ALB is deleted
  destroy_bucket_on_delete = false

  # S3 bucket to write logs to
  aws_log_bucket = "my-alb-logs"
}

# This makes an ecs cluster
module "ecs" {
  source     = "git::https://github.com/Janus-vistaprint/terraform-autoscale-ecs.git//tf_ecs_cluster"
  aws_region = "${var.aws_region}"

  # how much disk should a server have in gb

  asg_disk_size = 50
  # minmum amount of servers a cluster should have
  asg_min = "2"
  # desired amount of servers a cluster should have, just remember they will scale down so I'd set this to be enough to run twice the amount of containers you are requesting below
  asg_desired = "8"
  # how big do you want the cluster servers You can lookup ec2 types via google
  instance_type = "t2.small"
  #max number of servers a cluster should have
  asg_max      = "100"
  cluster_name = "${var.app_name}-${var.environment}"
  # the security group we should allow to forward traffic to this cluster. We use the lb's security group
  lb_security_group = "${module.alb.lb_security_group}"
  vpc_id            = "YOUR VPC ID"
  private_subnets   = ["subnet-ids"]
}

# This registers a "service" (a set of containers) in the cluster made above with the image tag specified. 
module "ecs_service" {
  source = "git::https://github.com/Janus-vistaprint/terraform-autoscale-ecs.git//tf_ecs_default_service"
  vpc_id = "YOUR VPCID"

  # the port in the container we should forward traffic to
  container_port = 80

  # the load balancer we should connec to
  lb_id = "${module.alb.lb_id}"

  # the port we should take traffic from
  lb_port = 80

  # each sever in the ecs cluster can host multiple containers

  # minium amount of containers we should always have
  containers_min = "2"
  # maximum amount of containers we should always have
  containers_max = "1000"
  # the amount of containers we would like to have
  containers_desired = "4"
  # soft limit for container memory in mb
  # WARNING: make sure you think about the ratio of cpu:memory to use the hardware effectively. So if you want 25% of a core, make sure you allocate atleast 25% of the memory as well
  container_memory_reservation = 500
  # hard limit for container memory (containers will be slain if they go over this)
  container_memory_hard = 1024
  # the cpu units a container can request. 1024 in a core, your server size will determine your avail cores
  # containers can go over the limit if resources are avalible 
  # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  containers_cpu_unit = 256
  # how many containers should always be around during deploy
  deployment_minimum_healthy_percent = "100"
  deployment_maximum_percent         = "200"
  deregistration_delay               = "300"

  #livecheck path

  livecheck_path = "/livecheck"

  # how often to check in seconds

  livecheck_interval = 10

  # how many checks are considered health

  livecheck_healthy_threshold = 6

  # how many checks failed are considered unhealthy

  livecheck_unhealthy_threshold = 2
  #docker tag url to ur container
  image_tag = "${var.image_tag}"
  #which cluster should we attach to
  cluster_arn = "${module.ecs.cluster_arn}"
  # name of the cluster we should attach to
  cluster_name = "${module.ecs.cluster_name}"
  #the name of this service
  task_name = "${var.app_name}"
  #the environment
  environment = "${var.environment}"
}

provider "aws" {
  region = "${var.aws_region}"
}


# aws region
variable "aws_region" {
  type = "string"
}

# the name of your application
variable "app_name" {
  type = "string"
}

#the environment we are deploying to
variable "environment" {
  type = "string"
}

# the docker tag of your container
variable "image_tag" {
  type = "string"
}


```
