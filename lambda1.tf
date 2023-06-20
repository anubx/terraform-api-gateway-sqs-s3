resource "aws_lambda_function" "lambda1" {
  function_name = "${var.app_name}-lambda1"
  filename      = "${path.module}/lambdas/lambda1/lambda1.zip"
  handler       = "lambda1.lambda_handler"
  role          = aws_iam_role.lambda1.arn
  runtime       = "python3.8"
  environment {
    variables = {
      sqs_queue = aws_sqs_queue.sqs.url
    }
  }
}

data "archive_file" "zip_lambda1" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda1"
  output_path = "${path.module}/lambdas/lambda1/lambda1.zip"
}

resource "aws_iam_role" "lambda1" {
  name = "lambda1-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "lambda1" {
  name = "lambda1-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
      }, {
      Effect = "Allow"
      Action = [
        "sqs:SendMessage"
      ]
      Resource = [aws_sqs_queue.sqs.arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda1" {
  policy_arn = aws_iam_policy.lambda1.arn
  role       = aws_iam_role.lambda1.name
}