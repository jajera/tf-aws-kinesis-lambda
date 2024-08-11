resource "aws_kinesis_stream" "example" {
  name             = local.name
  retention_period = 24
  shard_count      = 1
}

output "kinesis_data_stream_arn" {
  value = aws_kinesis_stream.example.arn
}
