terraform {
  backend "s3" {
    bucket         = "three-tier-tfstate-251128026767"
    region         = "ap-south-1"
    key            = "Jenkins-Server-TF/terraform.tfstate"
    dynamodb_table = "Lock-Files"
    encrypt        = true
  }
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source  = "hashicorp/aws"
    }
  }
}