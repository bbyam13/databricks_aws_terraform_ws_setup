# =============================================================================================
# Workspace Setup: Prod Environment
# =============================================================================================

module "prod_workspace" {
  source = "./modules/workspace_setup"

  providers = {
    databricks.mws               = databricks.mws
    databricks.created_workspace = databricks.prod_workspace #this must match the alias in the provider block
    aws                          = aws
  }

  # Dependencies from account level setup
  metastore_id                    = databricks_metastore.this.id
  admin_user                      = var.admin_user
  aws_account_id                  = var.aws_account_id
  databricks_account_id           = var.databricks_account_id
  region                          = var.region
  telemetry_bucket_name           = var.telemetry_bucket_name
  account_groups                  = databricks_group.groups

  #networking config
  vpc_cidr_range                  = "10.0.0.0/18"
  private_subnets_cidr            = ["10.0.0.0/22", "10.0.4.0/22"]
  public_subnets_cidr             = ["10.0.12.0/22", "10.0.16.0/22"]
  databricks_gov_shard            = null

  #variables per workspace 
  resource_prefix                 = "byam-prod" 
  telemetry_bucket_env_prefix     = "prod"
  deployment_name                 = "byam-prod"
  #Whether the catalog is accessible from all workspaces or a specific set of workspaces (ISOLATED or OPEN): https://registry.tf-registry-prod-use1.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog
  catalog_isolation_mode          = "OPEN"
}

#workspace specific outputs
output "prod_workspace_url" { #update this to match the module name
  value       = module.prod_workspace.databricks_host #update this to match the module name
  description = "Databricks workspace URL"
}

output "prod_workspace_service_principal_id" { #update this to match the module name
  value       = module.prod_workspace.service_principal_application_id #update this to match the module name
  description = "Service principal application ID for the workspace"
}

