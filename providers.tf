terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = "us-east-1"
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}
# GCP Provider Configuration
provider "google" {
  project = "your-gcp-project-id"
  region  = "us-central1"
  # Authentication is typically handled via local ADC or a JSON key file
  # credentials = file("path/to/service-account.json")
}
