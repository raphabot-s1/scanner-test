provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket"

  # Enable versioning
  versioning {
    enabled = false
  }

  # Enable server-side encryption by default
  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }

  # Block all public access
  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false

  # Enable logging
  # logging {
  #   target_bucket = "my-log-bucket"
  #   target_prefix = "log/"
  # }

  # Enable lifecycle rules
#   lifecycle_rule {
#     id      = "log"
#     enabled = true

#     prefix = "log/"
#     transition {
#       days          = 30
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = 365
#     }
#   }
}

resource "aws_s3_bucket_policy" "secure_bucket_policy" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:*"
        Effect = "Allow"
        Principal = "*"
        Resource = [
          "${aws_s3_bucket.secure_bucket.arn}",
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        },
        Action = "s3:GetObject"
        Effect = "Allow"
        Principal = "*"
        Resource = [
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
