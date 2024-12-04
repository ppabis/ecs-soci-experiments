variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.13.0.0/16"
}

variable "loadbalancer_allow_cidrs" {
  description = "CIDR blocks for load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}