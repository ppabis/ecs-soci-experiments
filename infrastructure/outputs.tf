output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.nginx.repository_url
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.sample_nginx.id
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

resource "local_file" "outputs_env" {
  content = <<-EOF
    ECR_REPO_URL=${aws_ecr_repository.nginx.repository_url}
    LOAD_BALANCER_DNS=${aws_lb.main.dns_name}
    ECS_SERVICE_ARN=${aws_ecs_service.sample_nginx.id}
    ECS_CLUSTER_NAME=${aws_ecs_cluster.main.name}
    EOF

  filename = "${path.module}/outputs.env"
}