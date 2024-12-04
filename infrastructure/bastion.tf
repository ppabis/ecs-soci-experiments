module "bastion" {
  # Change count to 1 if you want to spawn a bastion host to use via SSM
  count     = 0
  source    = "../bastion"
  vpc_id    = aws_vpc.main.id
  subnet_id = aws_subnet.public_1.id
}
