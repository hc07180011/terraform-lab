terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "app_server1" {
  ami           = "ami-08308a523776f7ece"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleInstance"
  }
}

resource "aws_instance" "app_server2" {
  ami           = "ami-08308a523776f7ece"
  instance_type = "t2.medium"

  tags = {
    Name = "ExampleInstance2"
  }
}