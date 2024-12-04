data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-arm64"
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion_security_group"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t4g.small"
  subnet_id                   = var.subnet_id
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 12
    volume_type = "gp3"
  }

  tags = {
    Name = "bastion-host"
  }
} 