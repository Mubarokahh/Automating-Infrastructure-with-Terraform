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
