# Terraform Documentation: https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_workspaces


# Wait on Credential Due to Race Condition
# https://kb.databricks.com/en_US/terraform/failed-credential-validation-checks-error-with-terraform 
resource "null_resource" "previous" {}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [null_resource.previous]
  create_duration = "60s"
}

# Credential Configuration
resource "databricks_mws_credentials" "this" {
  role_arn         = var.cross_account_role_arn
  credentials_name = "${var.resource_prefix}-credentials"
  depends_on       = [time_sleep.wait_60_seconds]
}

# Storage Configuration
resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  bucket_name                = var.bucket_name
  storage_configuration_name = "${var.resource_prefix}-storage"
}

# Network Configuration
resource "databricks_mws_networks" "this" {
  account_id         = var.databricks_account_id
  network_name       = "${var.resource_prefix}-network"
  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
}

resource "time_sleep" "wait_60_seconds_for_workspace" {
  depends_on = [databricks_mws_credentials.this, databricks_mws_networks.this]
  create_duration = "60s"
}

# Workspace Configuration with Deployment Name
resource "databricks_mws_workspaces" "workspace" {
  account_id                               = var.databricks_account_id
  aws_region                               = var.region
  workspace_name                           = var.resource_prefix
  credentials_id                           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id                 = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id                               = databricks_mws_networks.this.network_id
  pricing_tier                             = "ENTERPRISE"
  deployment_name                          = var.deployment_name
  is_no_public_ip_enabled                  = true  # Enable Secure Cluster Connectivity (SCC)

  depends_on = [databricks_mws_networks.this, time_sleep.wait_60_seconds_for_workspace]
}
