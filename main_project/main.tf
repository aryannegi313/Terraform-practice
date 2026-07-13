# Create the SSH key resources used by the EC2 instance.
module "ssh-key" {
    source = "./modules/ssh-key"
    key_name        = var.key_name
    private_key_path = var.private_key_path
}

# Example ingress rules for the demo environment.
locals {
  sg_ingress_rules = {
    http = { protocol = "tcp", from_port = 80, to_port = 80, cidr_ipv4 = "0.0.0.0/0" }
    ssh  = { protocol = "tcp", from_port = 22, to_port = 22, cidr_ipv4 = var.ssh_cidr }
  }

  sg_egress_rules = {
    none = { protocol = "-1", from_port = 0, to_port = 0, cidr_ipv4 = "0.0.0.0/0" }
  }
}

# Look up the latest Amazon Linux 2023 AMI in the configured region.
data "aws_ami" "amazon_linux"{
    owners = ["amazon"]
    most_recent = true

    filter {
        name   = "name"
        values = ["al2023-ami-*-x86_64"]
    }
}

# Create the main VPC for the demo infrastructure.
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true    
    tags = {
        Name = "main"
        Environment = "Dev"         
    }
}

# Deploy a public subnet that will host the EC2 instance.
resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allow_http_ssh" {
    vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ssh" {
    for_each = local.sg_ingress_rules
    security_group_id = aws_security_group.allow_http_ssh.id
    ip_protocol = each.value.protocol
    from_port = each.value.from_port
    to_port = each.value.to_port
    cidr_ipv4 = each.value.cidr_ipv4
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
    for_each = local.sg_egress_rules
    security_group_id = aws_security_group.allow_http_ssh.id
    ip_protocol = each.value.protocol
    cidr_ipv4 = each.value.cidr_ipv4
}

# Create the EC2 instance and attach the generated SSH key.
resource "aws_instance" "amazon_linux_ins" {
    ami = data.aws_ami.amazon_linux.id 
    instance_type = var.instance_type
    subnet_id = aws_subnet.main.id
    vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]
    key_name = module.ssh-key.key_name

    tags = {
        Name = "first-server-amazon-amazon_linux"
        Environment = var.environment
    }
}

# Generate an Ansible inventory file so the new server can be configured automatically.
resource "local_file" "ansible_inventory" {
    filename = "${path.root}/../ansible/inventory.ini"
    content = <<-EOT
[servers]
server1 ansible_host=${aws_instance.amazon_linux_ins.public_ip}  

[servers:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=${module.ssh-key.private_key_path}
EOT
}