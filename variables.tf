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
  description = "Azure subscription ID"
  type        = string
}

variable "azure_location" {
  description = "Azure region for the disaster-recovery environment"
  type        = string
  default     = "eastus"
}

variable "azure_image_tag" {
  description = "Image tag to deploy to Azure Container Apps"
  type        = string
  default     = "latest"
}

variable "enable_azure_container_app" {
  description = "Deploy the Azure Container App after pushing its image to ACR"
  type        = bool
  default     = false
}

variable "azure_dns_mode" {
  description = "DNS rollout stage: aws_only, azure_validation, or weighted"
  type        = string
  default     = "aws_only"

  validation {
    condition     = contains(["aws_only", "azure_validation", "weighted"], var.azure_dns_mode)
    error_message = "azure_dns_mode must be aws_only, azure_validation, or weighted."
  }
}

variable "enable_azure_custom_domain" {
  description = "Bind the shared hostname and uploaded certificate to the Azure Container App"
  type        = bool
  default     = false
}

variable "azure_certificate_pfx_path" {
  description = "Path to an SNI certificate in PFX format for the Azure Container App custom domain"
  type        = string
  default     = ""
}

variable "azure_certificate_password" {
  description = "Password for the Azure custom-domain PFX certificate"
  type        = string
  sensitive   = true
  default     = ""
}
variable "enable_azure_certificate" {
  description = "Enable uploading the TLS certificate to Azure."
  type        = bool
  default     = false
}