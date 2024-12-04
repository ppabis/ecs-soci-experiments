#################################################
#          ECS Cluster and Service              #
#################################################

resource "aws_ecs_cluster" "main" {
  name = "ecs-soci-cluster"
}

resource "aws_ecs_service" "sample_nginx" {
  name            = "sample-nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = false
    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "nginx"
    container_port   = 80
  }
}


########################################
#     ECS Tasks Security Group         #
########################################
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-soci-ecs-tasks-sg"
  tags        = { Name = "ecs-soci-ecs-tasks-sg" }
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow ingress traffic from ALB on port 80"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}