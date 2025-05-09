data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/cur-data-to-s3.py"
  output_path = "../lambda/cur-data-to-s3.zip"
}