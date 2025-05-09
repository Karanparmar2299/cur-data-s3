resource "aws_lambda_function" "cur_lambda" {
  function_name    = "cur-data-to-s3-function"
  role             = aws_iam_role.lambda_cur_role.arn
  handler          = "cur-data-to-s3.lambda_handler"
  runtime          = "python3.13"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  environment {
    variables = {
      S3_BUCKET   = aws_s3_bucket.cur_bucket.bucket
      CUR_RANGE   = var.CUR_RANGE
      REGION_NAME = var.REGION_NAME
    }
  }

}

resource "aws_cloudwatch_log_group" "cur_lambda_log" {
  name              = "/aws/lambda/${aws_lambda_function.cur_lambda.function_name}"
  retention_in_days = 14
}