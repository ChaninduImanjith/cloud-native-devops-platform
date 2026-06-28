terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }

  backend "s3" {
    # Using local backend for demonstration purposes, but in a real-world
    # scenario, this should point to an S3 bucket and DynamoDB table.
    # bucket         = "cloud-native-devops-platform-tf-state"
    # key            = "global/s3/terraform.tfstate"
    # region         = "us-east-1"
    # dynamodb_table = "terraform-up-and-running-locks"
    # encrypt        = true
  }
}
