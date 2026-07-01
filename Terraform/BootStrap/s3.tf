# Creating a secure and protected S3 Bucket
resource "aws_s3_bucket" "protected_bucket" {
  # 1. CHANGED: Added a unique suffix to avoid global naming conflicts
  bucket = "comercial-k8s-protected-storage-tomas-2026"

  force_destroy = true
  
  tags = {
    Name        = "Protected Infrastructure Storage"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.protected_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.protected_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. CHANGED: Switched to AES256 for instant creation without KMS API dependencies
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.protected_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
