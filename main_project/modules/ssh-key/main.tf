# Generate an RSA key pair that will be used to access the EC2 instance.
resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Save the private key to disk with restricted permissions.
resource "local_sensitive_file" "private_key" {
    content = tls_private_key.key.private_key_pem
    filename = var.private_key_path
    file_permission = "0600"
}

# Register the public key with AWS so the instance can be accessed over SSH.
resource "aws_key_pair" "public_key_aws" {
    key_name = var.key_name
    public_key = tls_private_key.key.public_key_openssh
}