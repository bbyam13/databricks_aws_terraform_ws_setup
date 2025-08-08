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
}

variable "user_name" {
  description = "your firstname.lastname"
}

variable "env" {
  description = "Environment name (dev, staging, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "private_link_service_relay" {
  description = "VPC endpoint service domains required for workspace to use AWS PrivateLink - SCC secure cluster connectivity relay"
}

variable "private_link_service_workspace" {
  description = "VPC endpoint service domains required for workspace to use AWS PrivateLink - the rest API"
}

provider "aws" {
    # provide AWS auth here
    region = var.region
}

provider "databricks" {
  alias    = "accounts"
  host     = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
}