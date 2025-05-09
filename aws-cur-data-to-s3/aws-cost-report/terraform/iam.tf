
# The IAM role for the Lambda function to assume.
resource "aws_iam_role" "lambda_cur_role" {
  name = "cur-data-to-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}   

# The IAM policy for the Lambda function to access AWS Cost Explorer and send emails.

resource "aws_iam_policy" "lambda_cur_policy" {
  name        = "cur-data-to-s3-policy"
  description = "Policy for Lambda to fetch cost data and upload to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ce:GetCostAndUsage"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        "s3:ListBucket"]
        Resource = "${aws_s3_bucket.cur_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_cur_policy_attachment" {
  role       = aws_iam_role.lambda_cur_role.name
  policy_arn = aws_iam_policy.lambda_cur_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_cur_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}