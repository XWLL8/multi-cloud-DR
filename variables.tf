variable "project_name" {
  type = string
}
variable "app_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "route53_zone_name" {
  description = "Name of the existing public Route 53 hosted zone, such as example.com"
  type        = string
}

variable "aws_region" {
  type = string
}
variable "container_port" {
  type = number
}