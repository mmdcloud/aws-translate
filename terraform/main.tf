module "lambda_function_code_bucket" {
  source      = "./modules/s3"
  bucket_name = "translatefunctioncodebucket"
  objects = [
    {
      key    = "lambda.zip"
      source = "./files/lambda.zip"
    }
  ]
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Disabled"
  force_destroy      = true
}

# Input bucket
module "source_bucket" {
  source        = "./modules/s3"
  bucket_name   = "sourcetranslatebucket"
  objects       = []
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Disabled"
  force_destroy      = true
}

# Output bucket
module "dest_bucket" {
  source        = "./modules/s3"
  bucket_name   = "desttranslatebucket"
  objects       = []
  bucket_policy = ""
  cors = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      max_age_seconds = 3000
    }
  ]
  versioning_enabled = "Disabled"
  force_destroy      = true
}

# IAM role for Lambda function
module "lambda_iam_role" {
  source             = "./modules/iam"
  role_name          = "lambda_function_iam_role_"
  role_description   = "lambda_function_iam_role_"
  policy_name        = "lambda_function_iam_policy_"
  policy_description = "lambda_function_iam_policy_"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                  "Service": "lambda.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
    }
    EOF
  policy             = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Action": [
                  "logs:CreateLogGroup",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:*:*",
                "Effect": "Allow"
            }            
        ]
    }
    EOF
}

# Lambda function
module "lambda_function" {
  source        = "./modules/lambda"
  function_name = "translate_function"
  role_arn      = module.lambda_iam_role.arn
  permissions   = []
  env_variables = {}
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  s3_bucket     = module.lambda_function_code_bucket.bucket
  s3_key        = "lambda.zip"
}