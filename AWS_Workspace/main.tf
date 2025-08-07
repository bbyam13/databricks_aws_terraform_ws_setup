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
  default = "YOUR AWS ACCOUNT ID"
}

variable "metastore_id" {
  type = string
  description = "Unity Catalog metastore id"
}

variable "cidr_block" {
  type = string
  description = "Databricks Workspace VPC CIDR"
}

variable "user_name" {
  description = "your firstname.lastname"
}

variable "env" {
  description = "Environment name (dev, staging, prod, etc.)"
  type        = string
  default     = "dev"
}

provider "aws" {
    # provide AWS auth here
    region = var.region
}

provider "databricks" {
  alias    = "accounts"
  host     = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
  # provide Databricks account auth here
}

locals {
  url = databricks_mws_workspaces.this.workspace_url
}

provider "databricks" {
  alias   = "workspace"
  host = local.url
  # provide Databricks workspace auth here
}

output "workspace_url" {
  value = local.url
  description = "Databricks workspace URL"
}

