output "key_name" {
  value = aws_key_pair.public_key_aws.key_name
}

output "private_key_path" {
  value = local_sensitive_file.private_key.filename
}

output "public_key" {
  value = tls_private_key.key.public_key_openssh
}