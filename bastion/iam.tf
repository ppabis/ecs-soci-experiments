resource "aws_iam_role" "bastion_role" {
  name = "bastion_ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}

########################################
#            Permissions               #
########################################
resource "aws_iam_role_policy_attachment" "bastion_cloudwatch_access" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecs_full_access" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

data "aws_iam_policy_document" "s3_read_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_exchange_bucket}",
      "arn:aws:s3:::${var.s3_exchange_bucket}/*"
    ]
  }
}

resource "aws_iam_role_policy" "s3_read_policy" {
  name   = "s3_read_policy"
  role   = aws_iam_role.bastion_role.id
  policy = data.aws_iam_policy_document.s3_read_policy.json
}