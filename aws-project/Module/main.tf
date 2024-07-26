data "archive_file" "lambda-func" {
  type        = "zip"
  source_dir  = var.source_file
  output_path = "../outputs/data_lake.zip"
  depends_on  = [null_resource.pip]
}

resource "aws_kms_key" "mykey" {
  description             = "Encryption for objects in data-lake-498"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "data-lake-498" {
  bucket = "data-lake-498"

}


resource "aws_s3_object" "lambda_zip" {

  bucket     = "data-lake-498"
  key        = "data_lake.zip"
  source     = "../outputs/data_lake.zip"
  depends_on = [data.archive_file.lambda-func]
}


resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "cloudwatchlogs1",
        "Action" : "logs:*",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "ses1",
        "Action" : [
          "ses:SendEmail"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "s3access",
        "Action" : [
          "s3:*",
          "s3-object-lambda:*"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Sid" : "kmsenc",
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "s3:GetObject"
        ],
        "Resource" : [
          "arn:aws:kms:us-east-1::mykey",
          "arn:aws:s3:::data-lake-498/*"
        ]
      },
      {
        "Sid" : "kmsdec",
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "null_resource" "pip" {

  triggers = {
    id = timestamp()
  }

  provisioner "local-exec" {
    working_dir = var.source_file
    command     = "pip install -r req.txt -t ."
  }
}

resource "aws_lambda_function" "data-lake" {

  depends_on    = [aws_s3_object.lambda_zip]
  s3_bucket     = "data-lake-498"
  s3_key        = "data_lake.zip"
  function_name = "data-lake"
  role          = aws_iam_role.lambda_role.arn
  handler       = "data_lake.lambda_handler"
  timeout       = 200

  #source_code_hash = filebase64sha256(data.archive_file.lambda-func.output_path)

  runtime = "python3.8"

  environment {
    variables = {
      SOURCE_EMAIL = var.src-email
      DEST_EMAIL   = var.rec-email
    }
  }

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data-lake.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data-lake-498.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data-lake-498.id

  lambda_function {

    lambda_function_arn = aws_lambda_function.data-lake.arn
    events              = ["s3:ObjectCreated:*"]

  }

  depends_on = [aws_lambda_permission.allow_bucket]
}


resource "aws_sns_topic" "alarms" {
  name = "file-upload-alarms"
}


resource "aws_cloudwatch_metric_alarm" "errors" {
  depends_on          = [aws_sns_topic.alarms]
  alarm_name          = "error count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "Execution Errors"
  treat_missing_data  = "ignore"

  dimensions = {
    FunctionName = "${aws_lambda_function.data-lake.function_name}"
  }

  insufficient_data_actions = [
    "${aws_sns_topic.alarms.arn}",
  ]

  alarm_actions = [
    "${aws_sns_topic.alarms.arn}",
  ]

  ok_actions = [
    "${aws_sns_topic.alarms.arn}",
  ]

}