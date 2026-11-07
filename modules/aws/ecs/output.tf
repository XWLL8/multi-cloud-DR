output "repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
output "repository_name" {
  value = aws_ecr_repository.app_repo.name
}
output "repository_arn" {
  value = aws_ecr_repository.app_repo.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.main_cluster.name
}

output "service_name" {
  value = try(aws_ecs_service.app_service[0].name, "")
}
