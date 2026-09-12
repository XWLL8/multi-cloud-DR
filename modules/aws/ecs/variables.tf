variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "container_port"  {
   type = number
    }

variable "project_name" {
  type = string
}