
resource "aws_s3_bucket" "staging" {
  bucket = local.name

  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "staging" {
  bucket = aws_s3_bucket.staging.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "staging" {
  bucket = aws_s3_bucket.staging.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.staging
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "staging" {
  bucket = aws_s3_bucket.staging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_notification" "staging" {
  bucket = aws_s3_bucket.staging.id
}

resource "aws_s3_object" "cognito_setup_yaml" {
  bucket = aws_s3_bucket.staging.bucket
  key    = "cognito-setup.yaml"
  source = "${path.module}/external/cognito-setup.yaml"
}

resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.staging.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "IPAllow"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.staging.arn}/*"
      Condition = {
        IpAddress = {
          "aws:SourceIp" = ["${data.http.my_public_ip.response_body}/32"]
        }
      }
    }]
  })
}

resource "aws_s3_bucket" "kinesis" {
  bucket = "${local.name}-kinesis"

  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "kinesis" {
  bucket = aws_s3_bucket.kinesis.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "kinesis" {
  bucket = aws_s3_bucket.kinesis.id
  acl    = "private"

  depends_on = [
    aws_s3_bucket_ownership_controls.kinesis
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kinesis" {
  bucket = aws_s3_bucket.kinesis.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
