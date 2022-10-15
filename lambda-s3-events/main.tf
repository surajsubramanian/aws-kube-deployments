provider "aws" {
  region = "us-east-1"
}

locals {
  source_bucket = aws_s3_bucket.source_bucket.id
  output_bucket = aws_s3_bucket.output_bucket.id
  account_id    = data.aws_caller_identity.current.account_id
  function = aws_lambda_function.pixelator
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "source_bucket" {
  bucket_prefix = "pixelator-source-"
  tags = {
    "About" = "Pixelator source bucket"
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket_prefix = "pixelator-output-"
  tags = {
    "About" = "Pixelator output bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "source_bucket_private" {
  bucket = aws_s3_bucket.source_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "destintion_bucket_private" {
  bucket = aws_s3_bucket.output_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "pixelator_policy" {
  name = "pixelator_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.source_bucket}",
          "arn:aws:s3:::${local.source_bucket}/*",
          "arn:aws:s3:::${local.output_bucket}/*",
          "arn:aws:s3:::${local.output_bucket}",
        ]
      },
      {
        Action = ["logs:CreateLogGroup"]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:us-east-1:${local.account_id}:*"
        ]
      },
      {
        Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:us-east-1:${local.account_id}:log-group:/aws/lambda/pixelator:*",
        ]
      },
    ]
  })
}

resource "aws_iam_role" "pixelator_role" {
  name = "pixelator_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.pixelator_role.name
  policy_arn = aws_iam_policy.pixelator_policy.arn
}

resource "aws_lambda_function" "pixelator" {
  filename      = "${path.module}/pixelator-dp.zip"
  function_name = "pixelator"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.pixelator_role.arn
  runtime       = "python3.9"
  environment {
    variables = {
        processed_bucket = "${local.output_bucket}"
    }
  }
  timeout = 60
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = "${local.source_bucket}"
    lambda_function {
      lambda_function_arn = "${local.function.arn}"
      events = ["s3:ObjectCreated:*"]
    }
    depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {
    statement_id = "AllowS3Invoke"
    action = "lambda:InvokeFunction"
    function_name = "${local.function.arn}"
    principal = "s3.amazonaws.com"
    source_arn = "arn:aws:s3:::${local.source_bucket}"
}
