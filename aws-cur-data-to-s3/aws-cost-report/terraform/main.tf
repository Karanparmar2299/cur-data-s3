provider "aws" {
  region = var.REGION_NAME
  #profile = "default"

  default_tags {
    tags = {
      "app-id"    = "12345"
      "app-name"  = "cur"
      "managedby" = "Terraform"
      "contact"     = "karanparmar2299@gmail.com"
    }
  }
}

terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "aws"
      version = "~> 5.0"
    }
  }
  #   backend "s3" {
  #     bucket = "karan-tf-bucket"
  #     key    = "cur/cur.tfstate"
  #     region = var.REGION_NAME
  #   }
}