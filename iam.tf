resource "aws_iam_role" "lambda_consumer" {
  name = "${local.name}-lambda-consumer"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_consumer" {
  name = "${local.name}-lambda-consumer"
  role = aws_iam_role.lambda_consumer.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${local.name}-consumer*"
      },
      {
        "Action" : [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards",
          "kinesis:ListStreams"
        ],
        "Resource" : [
          aws_kinesis_stream.example.arn
        ],
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_processor" {
  name = "${local.name}-lambda-processor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_processor" {
  name = "${local.name}-lambda-processor"
  role = aws_iam_role.lambda_processor.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/${local.name}-processor*"
      },
      {
        "Action" : [
          "kinesis:DescribeStream",
          "kinesis:DescribeStreamSummary",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards",
          "kinesis:ListStreams"
        ],
        "Resource" : [
          aws_kinesis_stream.example.arn
        ],
        "Effect" : "Allow"
      },
      {
        Effect   = "Allow",
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.kinesis.arn}/*"
      }
    ]
  })
}
