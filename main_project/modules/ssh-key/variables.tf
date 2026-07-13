variable "key_name" {
  description = "AWS EC2 key pair name"
  type        = string
  default = "terraform_key_first"
}

variable "private_key_path" {
  description = "Path where private PEM key will be stored"
  type        = string
  default = "/workspaces/Terraform-practice/main_project"
}