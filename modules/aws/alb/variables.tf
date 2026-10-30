variable "project_name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "public_subnet_ids" {
  type = list(string)
}

variable "certificate_arn" {
  type = string
}

variable "container_port" {
  type = number
}

variable "http_port" {
  type = number
}

variable "https_port" {
  type = number
}