terraform {
  backend "s3" {
    bucket         = "juliet-terraform-state-bucket-202510"
    key            = "dev/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks" # optional but recommended
    encrypt        = true
  }
}
