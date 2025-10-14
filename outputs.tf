output "api_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.us-west-2.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/items/{id}"
}
output "cognito_domain_url" {
  value       = "https://${aws_cognito_user_pool_domain.service_owned_domain.domain}.auth.us-west-2.amazoncognito.com"
  description = "Cognito Hosted UI / OAuth2 base URL"
}
output "cognito_password_grant_client_id" {
  description = "App client ID for ROPC testing"
  value       = aws_cognito_user_pool_client.password_grant_client.id
}