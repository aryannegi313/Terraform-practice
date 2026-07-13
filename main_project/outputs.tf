output "ec2_public_ip" {
  value = aws_instance.amazon_linux_ins.public_ip
}

output "ssh_private_key_path" {
  value = module.ssh-key.private_key_path
}