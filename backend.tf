  
  # versioning enables to view history of our state files
  resource "aws_s3_bucket" "terraform_state" {
  bucket = "mbarokah-dev-terraform-bucket-2"
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}


# Creating dynamoDB
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


  ## S3 backend resource block

  terraform {
  backend "s3" {
    bucket         = "mbarokah-dev-terraform-bucket-2"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
 