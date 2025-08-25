terraform {
  required_providers {
      databricks = {
          source = "databricks/databricks"
          version = "1.49.1"
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

variable "metastore_id" {
  type = string
  description = "Unity Catalog metastore id"
}


variable "user_name" {
  description = "your firstname.lastname"
}

variable "location_name" {
  description = "External location name"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name for external location"
  type        = string
}

provider "aws" {
   shared_credentials_files = ["/Users/brendan.byam/.aws/credentials"]
    profile = "332745928618_databricks-sandbox-admin"
    region = var.region
}

provider "databricks" {
  alias    = "accounts"
  host     = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  client_id     = "382c4e5b-8502-44e1-a575-990037bb5210"
  client_secret = "dose7eb93d43de6268ed5dbaf96da6f2dfb1"
  # provide Databricks account auth here
}

locals {
  url = "https://dbc-909b2eaf-e611.cloud.databricks.com"
}

provider "databricks" {
  alias   = "workspace"
  host = local.url
  client_id     = "382c4e5b-8502-44e1-a575-990037bb5210"
  client_secret = "dose7eb93d43de6268ed5dbaf96da6f2dfb1"
}

output "workspace_url" {
  value = local.url
  description = "Databricks workspace URL"
}

