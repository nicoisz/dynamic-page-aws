terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5"
}

provider "aws" {
  region = "us-east-1"
}

############################################
# SSM PARAMETER (DYNAMIC STRING)
############################################

resource "aws_ssm_parameter" "dynamic_string" {
  name  = "/app/dynamic-string"
  type  = "String"
  value = "hello world"
}

############################################
# IAM ROLE FOR LAMBDA
############################################

resource "aws_iam_role" "lambda_role" {
  name = "dynamic-page-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################################
# IAM POLICY (SSM + LOGS)
############################################

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda-ssm-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = aws_ssm_parameter.dynamic_string.arn
      },

      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }

    ]
  })
}

############################################
# PACKAGE LAMBDA
############################################

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./lambda"
  output_path = "./lambda.zip"
}

############################################
# LAMBDA FUNCTION
############################################

resource "aws_lambda_function" "dynamic_page" {

  function_name = "dynamic-page"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  handler = "handler.handler"
  runtime = "python3.12"

  environment {
    variables = {
      PARAM_NAME = aws_ssm_parameter.dynamic_string.name
    }
  }
}

############################################
# LAMBDA FUNCTION URL (PUBLIC)
############################################

resource "aws_lambda_function_url" "dynamic_page_url" {

  function_name = aws_lambda_function.dynamic_page.function_name

  authorization_type = "NONE"
}

############################################
# PUBLIC ACCESS PERMISSION
############################################

resource "aws_lambda_permission" "allow_public_url" {
  statement_id  = "AllowPublicInvokeFunctionURL"

  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.dynamic_page.function_name

  principal = "*"

  function_url_auth_type = "NONE"

  source_arn = aws_lambda_function_url.dynamic_page_url.function_arn
}

resource "aws_lambda_permission" "allow_public_invoke" {
  statement_id  = "AllowPublicInvokeFunction"

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.dynamic_page.function_name

  principal = "*"
}

############################################
# OUTPUT
############################################

output "url" {
  value = aws_lambda_function_url.dynamic_page_url.function_url
}