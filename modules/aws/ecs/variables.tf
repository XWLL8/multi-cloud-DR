variable "private_subnet_ids" {
  type = list(string)
}

variable "container_port" {
  type = number
}

variable "project_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "alb_security_group_id" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "alb_target_group_arn" {
  type = string
}
variable "create_ecs_service" {
  description = "Whether to create the ECS service"
  type        = bool
  default     = false
}