terraform {
    backend "s3" {
        bucket = "terrific-terraform-bucket"
        key = "terraform.tfstate"
        region = "eu-west-2"
        
    }

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
}
provider "aws" {
    region = "eu-west-2"
}

resource "aws_ecr_repository" "my_repository" {
  name = "bish-bash-bosh-repo"
  
  # Optional configurations
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

