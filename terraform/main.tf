# Input bucket
module "source_bucket" {
  source      = "../../modules/s3"
  bucket_name = "carshubmediaupdatefunctioncode${var.env}"
  objects = [
    {
      key    = "lambda.zip"
      source = "../../files/lambda.zip"
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
  versioning_enabled = "Enabled"
  force_destroy      = false
}

# Output bucket
module "dest_bucket" {
  source      = "../../modules/s3"
  bucket_name = "carshubmediaupdatefunctioncode${var.env}"
  objects = [
    {
      key    = "lambda.zip"
      source = "../../files/lambda.zip"
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
  versioning_enabled = "Enabled"
  force_destroy      = false
}

# IAM role for Lambda function
module "lambda_iam_role" {
  source             = "../../modules/iam"
  role_name          = "carshub_media_update_function_iam_role_${var.env}"
  role_description   = "carshub_media_update_function_iam_role_${var.env}"
  policy_name        = "carshub_media_update_function_iam_policy_${var.env}"
  policy_description = "carshub_media_update_function_iam_policy_${var.env}"
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
  source        = "../../modules/lambda"
  function_name = "carshub_media_update_${var.env}"
  role_arn      = module.carshub_media_update_function_iam_role.arn
  permissions   = []
  env_variables = {
    SECRET_NAME = module.carshub_db_credentials.name
    DB_HOST     = tostring(split(":", module.carshub_db.endpoint)[0])
    DB_NAME     = var.db_name
    REGION      = var.region
  }
  handler   = "lambda.lambda_handler"
  runtime   = "python3.12"
  s3_bucket = module.carshub_media_update_function_code.bucket
  s3_key    = "lambda.zip"
  layers    = [aws_lambda_layer_version.python_layer.arn]
  code_signing_config_arn = module.carshub_signing_profile.config_arn
}