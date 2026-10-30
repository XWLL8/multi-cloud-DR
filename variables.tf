variable "project_name" {
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

variable "http_port" {
  description = "Public HTTP listener port used to redirect traffic to HTTPS"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "Public HTTPS listener port"
  type        = number
  default     = 443
}
variable "create_ecs_service" {
  type    = bool
  default = false
}

variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}
variable "azure_location" {
  description = "Azure region for the DR environment"
  type        = string
  default     = "eastus"
}