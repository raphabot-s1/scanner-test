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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"  # Use AWS KMS encryption
        kms_master_key_id = "arn:aws:kms:us-west-2:123456789012:key/abcd1234-5678-90ab-cdef-ghijklmnopqr"  # Sample KMS Key ARN
      }
    }
  }

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

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.secure_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}