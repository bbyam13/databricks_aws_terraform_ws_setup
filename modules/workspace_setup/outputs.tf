output "databricks_host" {
  value = module.databricks_mws_workspace.workspace_url
}

output "service_principal_application_id" {
  value = databricks_service_principal.job_executor_sp.application_id
  description = "Service principal application ID"
}
