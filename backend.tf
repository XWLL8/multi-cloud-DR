terraform {
  backend "s3" {
    bucket       = "terraform-state-bucket-296062569552-us-east-1-an"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}