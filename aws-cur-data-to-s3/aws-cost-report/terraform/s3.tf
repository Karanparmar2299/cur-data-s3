resource "aws_s3_bucket" "cur_bucket" {
  bucket = "${data.aws_caller_identity.current.account_id}-cost-usage-reports"
}

resource "aws_s3_bucket_public_access_block" "cur_bucket_public_access" {
  bucket                  = aws_s3_bucket.cur_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "cur_bucket_lifecycle" {
  bucket = aws_s3_bucket.cur_bucket.id

  rule {
    id     = "ExpireOldCostReports"
    status = "Enabled"

    filter {
      prefix = "/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # Infrequent Access after 30 days
    }

    transition {
      days          = 60
      storage_class = "GLACIER" # Glacier after 60 days
    }

    expiration {
      days = 180 # Delete after 6 months
    }
  }
}


resource "aws_s3_bucket_policy" "cur_bucket_restrict_access" {
  bucket = aws_s3_bucket.cur_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowOnlyAccountAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.cur_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.cur_bucket.id}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:PrincipalAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cur_bucket_encryption" {
  bucket = aws_s3_bucket.cur_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}