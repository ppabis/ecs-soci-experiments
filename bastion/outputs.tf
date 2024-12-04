output "instance_id" {
  description = "The ID of the bastion instance"
  value       = aws_instance.bastion.id
}