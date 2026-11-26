resource "aws_s3_bucket" "app_package_bucket" {
  bucket = "heartbeat-app-package-109169735495"
  lifecycle { prevent_destroy = true }

}
resource "aws_s3_bucket_versioning" "app_package_bucket_versioning" {
  bucket = aws_s3_bucket.app_package_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "app_package_bucket_encryption" {
  bucket = aws_s3_bucket.app_package_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "app_package_bucket_lifecycle" {
  bucket = aws_s3_bucket.app_package_bucket.id
  rule {
    status = "Enabled"
    id     = "expire_old_packages"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app_package_bucket_public_access_block" {
  bucket                  = aws_s3_bucket.app_package_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}