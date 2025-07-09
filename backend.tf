terraform {
  backend "s3" {
    bucket         = "juliet-terraform-state-bucket-2025"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks" # optional but recommended
    encrypt        = true
  }
}
