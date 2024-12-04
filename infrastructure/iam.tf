################################
# ECS Task and Execution Roles #
################################
data "aws_iam_policy_document" "ecs_roles_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-soci-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_roles_assume.json
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-soci-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_roles_assume.json
}