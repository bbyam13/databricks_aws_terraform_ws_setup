output "metastore_id" {
  value       = databricks_metastore.this.id
  description = "Unity Catalog metastore ID"
}