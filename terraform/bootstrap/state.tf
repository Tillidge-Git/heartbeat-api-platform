
resource "aws_s3_bucket" "state_bucket" {
  #checkov:skip=CKV_AWS_144:CRR not required as architecture is single region, versioning and lifecycle rules are enabled to cover state recovery and retention requirements.
  #checkov:skip=CKV2_AWS_62:Notifications left out as nothing to consume notifications.
  #checkov:skip=CKV_AWS_18:Access is already restricted to two CI roles, plus admin and cloudtrail logs api access.
  bucket = "heartbeat-tfstate-109169735495"
  lifecycle { prevent_destroy = true }
  tags = {
    Name = "heartbeat-tfstate-109169735495"
  }

}

resource "aws_kms_key" "state_bucket_kms" {
  description             = "KMS key for encrypting the S3 bucket for Terraform state"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "state_bucket_key" {
  name          = "alias/heartbeat-tfstate-key"
  target_key_id = aws_kms_key.state_bucket_kms.key_id
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.state_bucket_kms.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}



resource "aws_s3_bucket_public_access_block" "state_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "state_bucket_lifecycle" {
  bucket     = aws_s3_bucket.state_bucket.id
  depends_on = [aws_s3_bucket_versioning.state_bucket_versioning]
  rule {
    status = "Enabled"
    id     = "expire_noncurrent_states"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
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