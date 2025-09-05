# Create job executor service principal for the workspace
resource "databricks_service_principal" "job_executor_sp" {
  provider     = databricks.created_workspace
  display_name = "${var.resource_prefix}-job-executor-sp"
  active       = true
  
  depends_on = [module.databricks_mws_workspace]
}

# Grant workspace admin permissions to the service principal
resource "databricks_mws_permission_assignment" "sp_workspace_admin" {
  provider       = databricks.mws
  workspace_id   = module.databricks_mws_workspace.workspace_id
  principal_id   = databricks_service_principal.job_executor_sp.id
  permissions    = ["ADMIN"]
}