variable "subnet_id" {
  description = "The ID of the subnet where the bastion host will be launched"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the bastion host will be launched"
  type        = string
}

variable "s3_exchange_bucket" {
  default     = "491c-8c9f-b545bbd4c877"
  description = "The name of the S3 bucket where the bastion host will exchange files with you"
  type        = string
}
