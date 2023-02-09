output "instance_id" {
    description = "instance id of created server"
    value       = aws_instance.bindecy
}
output "instance_public_ip" {
    description = "public ip of instance"
    value = aws_instance.bindecy.public_ip
}