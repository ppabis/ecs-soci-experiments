Experiments with SOCI images on AWS ECS
======================================

This is a companion repository to the following blog post:
[https://dev.to/aws-builders/speeding-up-ecs-containers-with-soci-5g5c](https://dev.to/aws-builders/speeding-up-ecs-containers-with-soci-5g5c).

Remember to specify your own variables in `infrastructure/terraform.tfvars`
based on `infrastructure/variables.tf`. You can also optionally create a bastion
host in AWS and connect to it via SSM to build and upload images faster.

Running the test script
----------------------

Run the script like this (use outputs from Terraform/Tofu):

```bash
export AWS_DEFAULT_REGION=eu-west-3
python test-startup-time.py \
 --service-arn arn:aws:ecs:eu-west-3:123456789012:service/ecs-soci-cluster/sample-nginx-service \
 --cluster-name ecs-soci-cluster \
 --load-balancer-dns ecs-soci-alb-8899001122.eu-west-3.elb.amazonaws.com
```
