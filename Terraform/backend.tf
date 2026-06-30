terraform {
  # Commercial Remote Backend Configuration
  backend "s3" {
    bucket         = "comercial-k8s-protected-storage-tomas-2026"
    key            = "infrastructure/terraform.tfstate" # Path inside the bucket
    region         = "eu-north-1"
    encrypt        = true
    dynamodb_table = "comercial-k8s-terraform-locks"
  }
}