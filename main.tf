terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.87.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.7"
    }
  }
  required_version = "~>1.3"
}
