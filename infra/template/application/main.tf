resource "aws_apigatewayv2_api" "backend" {
  name          = var.api_name
  protocol_type = "HTTP"
}
resource "aws_apigatewayv2_integration" "backend_lambda" {
  api_id               = aws_apigatewayv2_api.backend.id
  integration_type     = "AWS_PROXY"
  connection_type      = "INTERNET"
  description          = "backend Lambda Handler"
  integration_method   = "POST"
  integration_uri      = module.lambda_site.lambda_function_invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}
resource "aws_apigatewayv2_route" "backend_wildcard" {
  api_id    = aws_apigatewayv2_api.backend.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"
}
resource "aws_apigatewayv2_route" "backend_root" {
  api_id    = aws_apigatewayv2_api.backend.id
  route_key = "ANY /"
  target    = "integrations/${aws_apigatewayv2_integration.backend_lambda.id}"
}
resource "aws_apigatewayv2_stage" "backend-v1" {
  api_id      = aws_apigatewayv2_api.backend.id
  name        = "default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.backend_gateway.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

resource "aws_cloudwatch_log_group" "backend_gateway" {
  name              = "/aws/apig/${var.api_name}-logs"
  retention_in_days = 30
}

module "lambda_site" {
  source = "terraform-aws-modules/lambda/aws"

  function_name          = "serverless-http_issues_227"
  description            = "serverless-http_issues_227"
  handler                = "handler.handler"
  runtime                = "nodejs18.x"
  local_existing_package = var.site_dist_zip
  timeout                = 30

  publish        = false
  store_on_s3    = false
  create_package = false
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_site.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend.execution_arn}/*/*"
}
