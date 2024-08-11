resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name         = "kinesis-lambda-${random_string.suffix.result}"
  cognito_user = "cognito"
}

data "http" "my_public_ip" {
  url = "http://ifconfig.me/ip"
}

data "template_file" "consumer_js" {
  template = file("${path.module}/external/consumer.js")
}

data "archive_file" "consumer_js" {
  type        = "zip"
  output_path = "${path.module}/external/consumer.zip"

  source {
    content  = data.template_file.consumer_js.rendered
    filename = "index.js"
  }
}

data "template_file" "processor_mjs" {
  template = file("${path.module}/external/processor.mjs")
}

data "archive_file" "processor_mjs" {
  type        = "zip"
  output_path = "${path.module}/external/processor.zip"

  source {
    content  = data.template_file.processor_mjs.rendered
    filename = "index.mjs"
  }
}

resource "random_password" "cognito" {
  length      = 16
  min_lower   = 2
  min_numeric = 2
  min_upper   = 2
  special     = false
}
