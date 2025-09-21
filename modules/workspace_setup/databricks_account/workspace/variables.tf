variable "bucket_name" {
  description = "Name of the root S3 bucket for the workspace."
  type        = string
}

variable "cross_account_role_arn" {
  description = "AWS ARN of the cross-account role."
  type        = string
}

variable "databricks_account_id" {
  description = "ID of the Databricks account."
  type        = string
}

variable "deployment_name" {
  description = "Deployment name for the workspace. Must first be enabled by a Databricks representative."
  type        = string
  default     = null
  nullable    = true
}

variable "region" {
  description = "AWS region code."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "security_group_ids" {
  description = "Security group ID"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}