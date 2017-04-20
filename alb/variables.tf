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
