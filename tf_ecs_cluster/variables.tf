variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type"
}

variable "asg_disk_size" {
  description = "Size of root disk for instances in asg"
  default     = "50"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "2"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "1"
}

variable "private_subnets" {
  type = "list"
}

variable "cluster_name" {
  type = "string"
}

# The name of an ssh key to use
variable "key_name" {
  type    = "string"
  default = ""
}

variable "lb_security_group" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "cluster_memory_scale_out" {
  default = 70
}

variable "cluster_memory_scale_in" {
  default = 20
}

variable "cluster_cpu_scale_out" {
  default = 70
}

variable "cluster_cpu_scale_in" {
  default = 20
}
