resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "local_sensitive_file" "private_key" {
    content = tls_private_key.key.private_key_pem
    filename = var.private_key_path
    file_permission = "0600"
}

resource "aws_key_pair" "public_key_aws" {
    key_name = var.key_name
    public_key = tls_private_key.key.public_key_openssh
}