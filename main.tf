provider "aws" {
  region = "us-west-2"
}
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_sns_publish_policy" {
  name        = "LambdaSNSPublishPolicy"
  description = "Allow Lambda to publish to SNS topic"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          "sns:Publish"
        ],
        Resource : aws_sns_topic.alerts.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_publish" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_sns_publish_policy.arn
}

resource "aws_lambda_function" "api_handler" {
  function_name    = "serverless-api-handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler.handler"
  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      TABLE_NAME    = aws_dynamodb_table.items.name
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn

    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}





resource "aws_api_gateway_rest_api" "api" {
  name = "ServerlessAPI"
}

resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "items"
}

resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.items.id
  path_part   = "{id}"
}
# Reference an existing Cognito User Pool (created manually)
//data "aws_cognito_user_pool" "existing_user_pool" {
  //user_pool_id = "us-west-2_Ao1wBxP5V"
  //name = "MyAppUserPool"   # use the exact name shown in the console
//}
resource "aws_cognito_user_pool" "new_user_pool" {
  name = "MyNewUserPool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

 
}


resource "aws_api_gateway_authorizer" "cognito_auth" {
  name                    = "CognitoAuthorizer"
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.new_user_pool.arn]
  //provider_arns           = [data.aws_cognito_user_pool.existing_user_pool.arn]
  identity_source         = "method.request.header.Authorization"
}



resource "aws_api_gateway_method" "get_item" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "GET"
  //authorization = "NONE"
   authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

}
resource "aws_api_gateway_method" "post_item" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "POST"
  //authorization = "NONE"
   authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_auth.id

}
resource "aws_api_gateway_integration" "lambda_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.items.id
  http_method             = aws_api_gateway_method.post_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}


resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.item.id
  http_method             = aws_api_gateway_method.get_item.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}




resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.lambda_post_integration,
    aws_api_gateway_authorizer.cognito_auth,    # 👈 add this
    aws_api_gateway_method.get_item,
    aws_api_gateway_method.post_item
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  #stage_name  = "prod"
}
resource "aws_api_gateway_stage" "prod" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}

resource "aws_dynamodb_table" "items" {
  name         = "ItemsTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "lambda-insert-alerts"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "julietwainoi@gmail.com"
}

resource "aws_cognito_user_pool_domain" "service_owned_domain" {
  domain       = var.cognito_domain_prefix
  //user_pool_id = data.aws_cognito_user_pool.existing_user_pool.id
  user_pool_id  = aws_cognito_user_pool.new_user_pool.id
}

# -------------------------------------------------------------------
# Cognito App Client for Testing (Password Grant Enabled)
# -------------------------------------------------------------------

resource "aws_cognito_user_pool_client" "password_grant_client" {
  name         = "password-grant-client"
  user_pool_id  = aws_cognito_user_pool.new_user_pool.id
  //user_pool_id = data.aws_cognito_user_pool.existing_user_pool.id

  generate_secret = false  # must be false for password grant

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

  //allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows_user_pool_client = false


  allowed_oauth_flows = [
    "code",       # you can still allow this if needed
    "implicit"    # optional for browser-based auth
  ]

  allowed_oauth_scopes = [
    "openid",
    "email",
    "profile"
  ]

  callback_urls = ["https://example.com"]
  logout_urls   = ["https://example.com"]
}

