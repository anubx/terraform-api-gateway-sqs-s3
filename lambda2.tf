resource "aws_lambda_function" "lambda2" {
  function_name = "${var.app_name}-lambda2"
  filename      = "${path.module}/lambdas/lambda2/lambda2.zip"
  handler       = "lambda2.lambda_handler"
  role          = aws_iam_role.lambda2.arn
  runtime       = "python3.8"
  environment {
    variables = {
      s3_bucket = aws_s3_bucket.bucket.id
      region    = var.aws_region
    }
  }
}

data "archive_file" "zip_lambda2" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda2"
  output_path = "${path.module}/lambdas/lambda2/lambda2.zip"
}

resource "aws_iam_role" "lambda2" {
  name = "lambda2-role"
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

resource "aws_iam_policy" "lambda2" {
  name = "lambda2-policy"
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
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = [aws_sqs_queue.sqs.arn]
      }, {
      Effect = "Allow"
      Action = [
        "s3:PutObject"
      ]
      Resource = [
        "${aws_s3_bucket.bucket.arn}/*",
        aws_s3_bucket.bucket.arn
      ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda2" {
  policy_arn = aws_iam_policy.lambda2.arn
  role       = aws_iam_role.lambda2.name
}