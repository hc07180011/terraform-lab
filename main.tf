# https://github.com/terraform-aws-modules/terraform-aws-lambda

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

variable "lambda-entrypoint-num" {
  type = list(string)
  default = [ "1", "2" ]
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  for_each = toset(var.lambda-entrypoint-num)

  function_name = "my-lambda-existing-package-ecr${each.key}"
  description   = "Terraform Lambda test"

  create_package = false

  image_uri    = "434648438593.dkr.ecr.ap-northeast-1.amazonaws.com/hello-world:latest"
  image_config_command = ["app.handler${each.key}"]

  package_type = "Image"
}