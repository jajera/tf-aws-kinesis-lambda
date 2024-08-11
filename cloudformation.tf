resource "aws_cloudformation_stack" "cognito_setup" {
  name         = "${local.name}-cognito-setup"
  template_url = "https://${aws_s3_bucket.staging.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/cognito-setup.yaml"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  on_failure = "DELETE"

  parameters = {
    Username = "cognito"
    Password = random_password.cognito.result
  }

  timeout_in_minutes = 30
}

output "cognito_setup_url" {
  value = "https://${aws_s3_bucket.staging.bucket}.s3.${data.aws_region.current.name}.amazonaws.com/cognito-setup.yaml"
}

output "kinesis_data_generator_url" {
  value = aws_cloudformation_stack.cognito_setup.outputs["KinesisDataGeneratorUrl"]
}

output "kinesis_data_generator_cognito_user" {
  value = aws_cloudformation_stack.cognito_setup.outputs["KinesisDataGeneratorCognitoUser"]
}

output "kinesis_data_generator_s3_bucket_name" {
  value = aws_cloudformation_stack.cognito_setup.outputs["S3BucketName"]
}
