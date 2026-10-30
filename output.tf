output "application_url" {
  description = "HTTPS URL for the application"
  value       = "https://${var.domain_name}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the application VPC"
  value       = module.vpc.vpc_id
}

output "ecr_repository_url" {
  description = "URL of the application ECR repository"
  value       = module.ecs.repository_url
}

output "ecr_repository_name" {
  description = "Name of the application ECR repository"
  value       = module.ecs.repository_name
}