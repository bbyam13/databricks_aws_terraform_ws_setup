# Create Databricks Workspace
module "databricks_mws_workspace" {
  source = "./databricks_account/workspace"

  providers = {
    databricks = databricks.mws
  }

  # Basic Configuration
  databricks_account_id = var.databricks_account_id
  resource_prefix       = var.resource_prefix
  region                = var.region
  deployment_name       = var.deployment_name

  # Network Configuration
  vpc_id             = var.custom_vpc_id != null ? var.custom_vpc_id : module.vpc.vpc_id
  subnet_ids         = var.custom_private_subnet_ids != null ? var.custom_private_subnet_ids : module.vpc.private_subnets
  security_group_ids = [aws_security_group.sg.id]

  # Cross-Account Role
  cross_account_role_arn = aws_iam_role.cross_account_role.arn

  # Root Storage Bucket
  bucket_name = aws_s3_bucket.root_storage_bucket.id
}

# Unity Catalog Assignment
module "unity_catalog_metastore_assignment" {
  source = "./databricks_account/unity_catalog_metastore_assignment"
  providers = {
    databricks = databricks.mws
  }

  metastore_id = var.metastore_id
  workspace_id = module.databricks_mws_workspace.workspace_id

  depends_on = [ module.databricks_mws_workspace]
}

# User Workspace Assignment (Admin)
module "user_assignment" {
  source = "./databricks_account/user_assignment"
  providers = {
    databricks = databricks.mws
  }

  workspace_id     = module.databricks_mws_workspace.workspace_id
  workspace_access = var.admin_user

  depends_on = [module.unity_catalog_metastore_assignment, module.databricks_mws_workspace]
}

# =============================================================================
# Databricks Workspace Modules
# =============================================================================

# Creates a Workspace Catalog
module "unity_catalog_catalog_creation" {
  source = "./databricks_workspace/unity_catalog_catalog_creation"
  providers = {
    databricks = databricks.created_workspace
  }

  aws_account_id               = var.aws_account_id
  aws_iam_partition            = local.computed_aws_partition
  aws_assume_partition         = local.assume_role_partition
  unity_catalog_iam_arn        = local.unity_catalog_iam_arn
  resource_prefix              = var.resource_prefix
  uc_catalog_name              = "${var.resource_prefix}-catalog"
  cmk_admin_arn                = var.cmk_admin_arn == null ? "arn:${local.computed_aws_partition}:iam::${var.aws_account_id}:root" : var.cmk_admin_arn
  workspace_id                 = module.databricks_mws_workspace.workspace_id
  user_workspace_catalog_admin = var.admin_user
  catalog_isolation_mode       = var.catalog_isolation_mode

  depends_on = [module.unity_catalog_metastore_assignment]
}

# System Table Schemas Enablement
module "system_table" {
  count  = var.region == "us-gov-west-1" ? 0 : 1
  source = "./databricks_workspace/system_schema"
  providers = {
    databricks = databricks.created_workspace
  }
  depends_on = [module.unity_catalog_metastore_assignment]
}

# Restrictive Root Buckt Policy
module "restrictive_root_bucket" {
  source = "./databricks_workspace/restrictive_root_bucket"
  providers = {
    aws = aws
  }

  databricks_account_id = var.databricks_account_id
  aws_partition         = local.computed_aws_partition
  databricks_gov_shard  = var.databricks_gov_shard
  workspace_id          = module.databricks_mws_workspace.workspace_id
  region_name           = var.databricks_gov_shard == "dod" ? var.region_name_config[var.region].secondary_name : var.region_name_config[var.region].primary_name
  root_s3_bucket        = "${var.resource_prefix}-workspace-root-storage"
}


module "telemetry_location" {
  count  = var.telemetry_bucket_name != null ? 1 : 0
  source = "./databricks_workspace/telemetry_external_location"
  providers = {
    databricks = databricks.created_workspace
  }

  databricks_account_id             = var.databricks_account_id
  aws_account_id                    = var.aws_account_id
  resource_prefix                   = var.resource_prefix
  telemetry_bucket_name             = var.telemetry_bucket_name
  telemetry_bucket_env_prefix       = var.telemetry_bucket_env_prefix
  read_only_external_location_admin = var.admin_user
  depends_on = [module.unity_catalog_metastore_assignment]
}