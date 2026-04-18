terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# GCP Provider Configuration
provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
  # Authentication is typically handled via local ADC or a JSON key file
  # credentials = file("path/to/service-account.json")
}
