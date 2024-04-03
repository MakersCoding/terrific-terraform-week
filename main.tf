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

