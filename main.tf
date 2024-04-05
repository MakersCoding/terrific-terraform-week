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

  required_version = ">=1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_ecr_repository" "my_repository" {
  name                 = "bish-bash-bosh-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_elastic_beanstalk_application" "bish_bash_bosh_app" {
  name        = "bish-bash-bosh-task-listing-app"
  description = "Task listing app"
}

resource "aws_db_instance" "bishbashboshdb" {
  allocated_storage   = 10
  engine              = "postgres"
  engine_version      = "15.3"
  instance_class      = "db.t3.micro"
  identifier          = "bishbashboshdb"
  db_name             = "bishdbname"
  username            = "thebosh"
  password            = "bishbashbosh"
  skip_final_snapshot = true
  publicly_accessible = true
}

resource "aws_elastic_beanstalk_environment" "bish_bash_bosh_app_environment" {
  name                = "bi-ba-bo-task-list-app-env"
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

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_HOSTNAME"
    value     = aws_db_instance.bishbashboshdb.endpoint
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PORT"
    value     = aws_db_instance.bishbashboshdb.port
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_DB_NAME"
    value     = aws_db_instance.bishbashboshdb.db_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_USERNAME"
    value     = aws_db_instance.bishbashboshdb.username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PASSWORD"
    value     = aws_db_instance.bishbashboshdb.password
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
  })
}

resource "aws_s3_bucket" "docker_deploy_bucket" {
  bucket = "bish-bash-bucket"
  acl    = "private"
}

resource "aws_iam_role_policy_attachment" "web_tier" {
  role       = aws_iam_role.bish_bash_bosh_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "multi_container_docker" {
  role       = aws_iam_role.bish_bash_bosh_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "worker_tier" {
  role       = aws_iam_role.bish_bash_bosh_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "example_app_ec2_role_policy_attachment" {
  role       = aws_iam_role.bish_bash_bosh_app_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "bish_bash_bosh_app_ec2_instance_profile" {
  name = "bish-bash-bosh-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.bish_bash_bosh_app_ec2_role.name
}