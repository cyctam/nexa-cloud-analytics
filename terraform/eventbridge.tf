resource "aws_cloudwatch_event_rule" "s3_trigger" {
  name        = "${var.project_prefix}-s3-trigger"
  description = "Trigger Step Functions when new file lands in raw bucket"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = { name = [aws_s3_bucket.raw.bucket] }
      object = { key = [{ prefix = "transactions/" }, { prefix = "shipments/" }, { prefix = "sellers/" }] }
    }
  })
}

resource "aws_cloudwatch_event_target" "sfn_target" {
  rule      = aws_cloudwatch_event_rule.s3_trigger.name
  target_id = "StepFunctions"
  arn       = aws_sfn_state_machine.pipeline.arn
  role_arn  = aws_iam_role.eventbridge_role.arn

  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
      time   = "$.time"
    }
    input_template = "{\"bucket\": \"<bucket>\", \"key\": \"<key>\", \"timestamp\": \"<time>\"}"
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name = "${var.project_prefix}-eventbridge-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_sfn" {
  role = aws_iam_role.eventbridge_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["states:StartExecution"]
      Resource = aws_sfn_state_machine.pipeline.arn
    }]
  })
}