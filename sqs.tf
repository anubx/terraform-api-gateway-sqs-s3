resource "aws_sqs_queue" "sqs" {
  name = "${var.app_name}-sqs-queue"
}

resource "aws_sqs_queue_policy" "my_sqs_policy" {
  queue_url = aws_sqs_queue.sqs.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "sqspolicy",
    "Statement": [
    {
        "Sid": "First",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "sqs:SendMessage",
        "Resource": "${aws_sqs_queue.sqs.arn}"
    }
    ]
}
POLICY
}

resource "aws_lambda_event_source_mapping" "consumer-sqs" {
  event_source_arn = aws_sqs_queue.sqs.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda2.arn

  depends_on = [
    aws_sqs_queue.sqs
  ]
}