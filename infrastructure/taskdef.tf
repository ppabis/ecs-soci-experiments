locals {
  container_tag = fileexists("tag.txt") ? file("tag.txt") : "latest"
}

resource "aws_cloudwatch_log_group" "sample_nginx" {
  name              = "/ecs/sample_nginx"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "sample-nginx"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode(
    yamldecode(
      templatefile("containers.yaml", {
        ContainerImage = "${aws_ecr_repository.nginx.repository_url}:${local.container_tag}"
        LogGroupName   = aws_cloudwatch_log_group.sample_nginx.name
        Region         = var.aws_region
      })
    )
  )
}
