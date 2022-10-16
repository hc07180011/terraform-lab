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
  type    = list(string)
  default = ["1", "2"]
}

resource "aws_ecr_repository" "hello_world_repo" {
  name = "hello-world"
}

resource "aws_ecr_repository_policy" "hello_world_repo_policy" {
  repository = aws_ecr_repository.hello_world_repo.name

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "LambdaECRImageRetrievalPolicy",
            "Effect": "Allow",
            "Principal": "lambda.amazonaws.com",
            "Action": [
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy",
                "ecr:GetRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "hello_world_lifecycle_policy" {
  repository = aws_ecr_repository.hello_world_repo.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Not more than 10",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "null_resource" "docker_image1" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 434648438593.dkr.ecr.ap-northeast-1.amazonaws.com
      docker build -t $REGISTRY/$REPOSITORY:$IMAGE_TAG .
      docker push $REGISTRY/$REPOSITORY:$IMAGE_TAG
    EOT
    environment = {
      REGISTRY   = "434648438593.dkr.ecr.ap-northeast-1.amazonaws.com"
      REPOSITORY = "hello-world"
      IMAGE_TAG  = "latest"
    }
  }

  depends_on = [
    aws_ecr_repository.hello_world_repo
  ]
}

module "lambda_function_container_image" {
  source = "terraform-aws-modules/lambda/aws"

  for_each = toset(var.lambda-entrypoint-num)

  function_name = "my-lambda-existing-package-ecr${each.key}"
  description   = "Terraform Lambda test"

  create_package = false

  image_uri            = "434648438593.dkr.ecr.ap-northeast-1.amazonaws.com/hello-world:latest"
  image_config_command = ["app.handler${each.key}"]

  package_type = "Image"

  depends_on = [
    null_resource.docker_image1
  ]
}