resource "aws_ecr_repository" "nginx" {
  name                 = "sample/nginx"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository_policy" "nginx_policy" {
  repository = aws_ecr_repository.nginx.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPullFromECS"
        Effect    = "Allow"
        Principal = { Service = "ecs.amazonaws.com" }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
} 