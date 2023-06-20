resource "aws_lambda_function" "lambda3" {
  function_name = "${var.app_name}-lambda3"
  filename      = "${path.module}/lambdas/lambda3/lambda3.zip"
  handler       = "lambda3.lambda_handler"
  role          = aws_iam_role.lambda3.arn
  runtime       = "python3.8"
}

data "archive_file" "zip_lambda3" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas/lambda3"
  output_path = "${path.module}/lambdas/lambda3/lambda3.zip"
}

resource "aws_iam_role" "lambda3" {
  name = "lambda3-role"
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

resource "aws_iam_policy" "lambda3" {
  name = "lambda3-policy"
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
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "${aws_s3_bucket.bucket.arn}/*",
        aws_s3_bucket.bucket.arn
      ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda3" {
  policy_arn = aws_iam_policy.lambda3.arn
  role       = aws_iam_role.lambda3.name
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda3.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}