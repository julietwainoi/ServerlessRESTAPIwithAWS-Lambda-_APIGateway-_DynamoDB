output "api_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-west-2.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/items/{id}"
}
