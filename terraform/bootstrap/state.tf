resource "aws_s3_bucket" "state_bucket" {
  bucket = "heartbeat-tfstate-109169735495"
  lifecycle { prevent_destroy = true }
  tags = {
    Name = "heartbeat-tfstate-109169735495"
  }

}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "state_bucket_policy" {
  bucket     = aws_s3_bucket.state_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.state_bucket_public_access_block]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.state_bucket.arn}/*",
          aws_s3_bucket.state_bucket.arn
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