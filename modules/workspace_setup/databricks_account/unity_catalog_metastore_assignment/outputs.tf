output "metastore_assignment" {
  value = databricks_metastore_assignment.default_metastore.id
  #need output to make telemetry location depend on it
}