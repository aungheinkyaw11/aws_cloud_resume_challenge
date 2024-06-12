resource "aws_iam_role" "Cloud_Challenge_Lambda_Function_Role" {
name   = "Cloud_Challenge_Lambda_Function_Role"
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

resource "aws_iam_policy" "Cloud_Challenge_iam_policy" {
name        = "Cloud_Challenge_iam_policy"
path        = "/"
description = "AWS IAM Policy for managing the resume project role"
policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "arn:aws:logs:*:*:*",
          "Effect" : "Allow"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "dynamodb:UpdateItem",
			      "dynamodb:GetItem",
            "dynamodb:PutItem"
          ],
          "Resource" : "arn:aws:dynamodb:*:*:table/Cloud_Challenge"
        },
      ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role = aws_iam_role.Cloud_Challenge_Lambda_Function_Role.name
  policy_arn = aws_iam_policy.Cloud_Challenge_iam_policy.arn
  
}


resource "aws_lambda_function" "Cloud_Challenge_lambda" {
  filename      = data.archive_file.zip_the_python_code.output_path
  function_name = "Cloud_Challenge_lambda"
  role          = aws_iam_role.Cloud_Challenge_Lambda_Function_Role.arn
  handler       = "func.lambda_handler"
  runtime       = "python3.8"
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_file = "${path.module}/lambda/func.py"
  output_path = "${path.module}/lambda/func.zip"
}


resource "aws_lambda_function_url" "test_live" {
  function_name      = aws_lambda_function.Cloud_Challenge_lambda.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

output "lambda_function_url" {
  value = aws_lambda_function_url.test_live.function_url
}


resource "aws_dynamodb_table_item" "Cloud_Challenge_item" {
  table_name = aws_dynamodb_table.Cloud_Challenge.name
  hash_key   = aws_dynamodb_table.Cloud_Challenge.hash_key

  item = <<ITEM
{
  "id": {"S": "0"},
  "views": {"N": "0"}
}
ITEM
}

resource "aws_dynamodb_table" "Cloud_Challenge" {
  name           = "Cloud_Challenge"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}