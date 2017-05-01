variable "public_subnets" {
  description = ""
  type        = "list"
}

variable "lb_name" {
  description = "lb name"
  type        = "string"
}

variable "lb_port" {
  default = [80]
}

variable "vpc_id" {
  type = "string"
}

variable "route53_dns_name" {
  description = "Public DNS name used to refer to this ALB"
  type        = "string"
  default     = ""
}

variable "route53_dns_zone_id" {
  description = "Zone ID for Route 53"
  type        = "string"
  default     = ""
}
