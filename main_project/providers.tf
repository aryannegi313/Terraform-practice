terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~>6.0"
        }
        tls = {
            source = "hashicorp/tls"
            version = "~>4.0"
        }
        local = {
            source = "hashicorp/local"
            version = "~>2.0"
        }
    }
    
    backend "s3" {
        bucket = "terraform-state-file-aryan-7-12-2026"
        key    = "free-tier-demo/terraform.tfstate"
        region = "us-east-1"
        dynamodb_table = "terraform-locks"
        encrypt= true
    }

    required_version = ">=1.2"
}

provider aws {
    region = "us-east-1"
}