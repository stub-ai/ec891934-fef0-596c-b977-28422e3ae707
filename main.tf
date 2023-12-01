provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c574c8"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}

resource "aws_dynamodb_table" "example" {
  name           = "example-table"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "N"
  }
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  acl    = "private"

  tags = {
    Name = "example-bucket"
  }
}

resource "aws_lambda_function" "example" {
  function_name = "example-function"
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.example.arn

  filename = "lambda_function_payload.zip"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      BUCKET = aws_s3_bucket.example.bucket
    }
  }
}

resource "aws_iam_role" "example" {
  name = "example-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "example" {
  name = "example-policy"
  role = aws_iam_role.example.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}