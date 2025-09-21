terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "1.87.1"
      configuration_aliases = [
        databricks.mws,
        databricks.created_workspace
      ]
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
}
