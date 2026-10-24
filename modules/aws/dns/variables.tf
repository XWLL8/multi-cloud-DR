variable "domain_name" {
  description = "Hostname to secure and point to the ALB, such as app.example.com"
  type        = string
}

variable "route53_zone_name" {
  description = "Existing public Route 53 hosted zone name, such as example.com"
  type        = string
}
