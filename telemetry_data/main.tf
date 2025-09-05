terraform {
  required_providers {
      databricks = {
          source = "databricks/databricks"
          version = "1.87.1"
      }
      aws = {
          source = "hashicorp/aws"
      }
  }
}

variable "region" { 
  type = string
  default = "us-east-1"
}

variable "databricks_account_id" {
  type = string
  description = "Databricks account id from accounts console"
}

variable "databricks_aws_account_id" {
  type = string
  description = "Databricks AWS account id"
  default = "414351767826"
}

variable "user_name" {
  description = "your firstname.lastname"
}

variable "workspace_url" {
  type = string
  description = "workspace url - required to create an external location for telemetry data"
}

variable "telemetry_bucket_name" {
  description = "S3 bucket name for external location"
  type        = string
}

variable "telemetry_location_name" {
  type = string
  description = "Telemetry external location name"
}

provider "aws" {
   # provide aws credentials here
  region = var.region
}

provider "databricks" {
  alias    = "accounts"
  host     = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  # provide Databricks account auth here
}

provider "databricks" {
  alias   = "workspace"
  host = var.workspace_url
  # provide Databricks workspace auth here
}

