resource "aws_lambda_function" "consumer" {
  function_name    = "${local.name}-consumer"
  filename         = "${path.module}/external/consumer.zip"
  handler          = "index.handler"
  role             = aws_iam_role.lambda_consumer.arn
  runtime          = "nodejs20.x"
  source_code_hash = base64sha256(file("${path.module}/external/consumer.js"))
  timeout          = 60

  depends_on = [
    aws_cloudwatch_log_group.consumer
  ]
}

resource "aws_lambda_event_source_mapping" "consumer" {
  event_source_arn  = aws_kinesis_stream.example.arn
  function_name     = aws_lambda_function.consumer.arn
  starting_position = "LATEST"
}

resource "aws_lambda_function" "processor" {
  function_name    = "${local.name}-processor"
  filename         = "${path.module}/external/processor.zip"
  handler          = "index.handler"
  role             = aws_iam_role.lambda_processor.arn
  runtime          = "nodejs20.x"
  source_code_hash = base64sha256(file("${path.module}/external/processor.mjs"))
  timeout          = 60

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.kinesis.bucket
      PREFIX      = "kinesis/"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.processor
  ]
}

resource "aws_lambda_event_source_mapping" "processor" {
  event_source_arn  = aws_kinesis_stream.example.arn
  function_name     = aws_lambda_function.processor.arn
  starting_position = "LATEST"
}

output "lambda_consumer_function_arn" {
  value = aws_lambda_function.consumer.arn
}
