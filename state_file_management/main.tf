esource "aws_s3_bucket" "state_file" {
    bucket = "terraform-state-file-aryan-7-12-2026"

    tags = {
        Name = "State store"
        Environment = "Dev"
    }
}

resource "aws_s3_bucket_versioning" "bucket_versionig" {
    bucket = aws_s3_bucket.state_file.id
    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_dynamodb_table" "state_lock_table" {
    name = "terraform-locks"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key = "LockID"
    
    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Name = "State store db"
        Environment = "Dev"
    }    
}
