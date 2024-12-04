module "bastion" {
  # Change count to 1 if you want to spawn a bastion host to use via SSM
  # also change the S3 bucket in copy-resources.sh and here to your own existing bucket.
  # Or create a new bucket as another resouce here :D
  count              = 0
  source             = "../bastion"
  vpc_id             = aws_vpc.main.id
  subnet_id          = aws_subnet.public_1.id
  s3_exchange_bucket = "491c-8c9f-b545bbd4c877"
}
