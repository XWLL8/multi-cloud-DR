terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket" # Create this manually first
    prefix = "terraform/state"
  }
}