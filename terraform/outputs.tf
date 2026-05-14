output "instance_public_ip" {
  description = "L'adresse IP publique de l'instance"
  value       = aws_instance.vm.public_ip
}
