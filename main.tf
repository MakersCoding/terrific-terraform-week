terraform {
  backend "s3" {
    bucket = "terrific-terraform-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-2"

  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
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

resource "aws_elastic_beanstalk_application" "bish_bash_bosh_app" {
  name        = "bish-bash-bosh-task-listing-app"
  description = "Task listing app"
}

resource "aws_elastic_beanstalk_environment" "bish_bash_bosh_app_environment" {
  name                = "bish-bash-bosh-task-listing-app-environment"
  application         = aws_elastic_beanstalk_application.bish_bash_bosh_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.bish_bash_bosh_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "bish-bash-bosh"
  }
}

resource "aws_iam_role" "bish_bash_bosh_app_ec2_role" {
  name = "bish-bash-bosh-task-listing-app-ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
    ManagedPolicyArns = [
      "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier",
      "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker",
      "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
    ]
  })
}

resource "aws_iam_instance_profile" "bish_bash_bosh_app_ec2_instance_profile" {
  name = "bish-bash-bosh-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.bish_bash_bosh_app_ec2_role.name
}