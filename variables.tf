# Optionally define AWS region or Lambda settings
variable "cognito_domain_prefix" {
  description = "Unique prefix for the Cognito hosted domain (must be globally unique across AWS)"
  type        = string
  default     = "myappdemo123"
}
