variable "admin_user" {
  description = "Email of the admin user for the workspace and workspace catalog."
  type        = string
}

variable "executor_application_id" {
  description = "Application ID of the executor service principal"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  description = "ID of the AWS account."
  type        = string
  sensitive   = true
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region code. (e.g. us-east-1)"
  type        = string
  validation {
    condition     = contains(["ap-northeast-1", "ap-northeast-2", "ap-south-1", "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ca-central-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-west-3", "sa-east-1", "us-east-1", "us-east-2", "us-west-1", "us-west-2", "us-gov-west-1"], var.region)
    error_message = "Valid values for var: region are (ap-northeast-1, ap-northeast-2, ap-south-1, ap-southeast-1, ap-southeast-2, ap-southeast-3, ca-central-1, eu-central-1, eu-west-1, eu-west-2, eu-west-3, sa-east-1, us-east-1, us-east-2, us-west-1, us-west-2, us-gov-west-1)."
  }
}

variable "metastore_name" {
  description = "Name of the metastore"
  type        = string
}

variable "databricks_provider_host" {
  description = "Databricks provider host URL"
  type        = string
  default     = null 

  validation {
    condition     = var.databricks_provider_host == null || can(regex("^https://(accounts|accounts-dod)\\.cloud\\.databricks\\.(com|us|mil)$", var.databricks_provider_host))
    error_message = "Invalid databricks_provider_host. Must be a valid Databricks accounts URL."
  }
}

# =============================================================================
# Telemetry Bucket Configuration Variables
# =============================================================================

variable "telemetry_bucket_env_prefix" {
  description = "Maps to the telemetry bucket prefix for each environment"
  type        = string
  default     = null
}

variable "telemetry_bucket_name" {
  description = "Telemetry bucket name"
  type        = string
  default     = null
}

# Combined locals block for all computed values
locals {
  computed_databricks_provider_host ="https://accounts.cloud.databricks.com"
}