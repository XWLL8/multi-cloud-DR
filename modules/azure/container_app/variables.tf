variable "project_name" {
  type = string
}
variable "environment_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_port" {
  type = number
}

variable "registry_server" {
  type = string
}

variable "registry_identity_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}