output "catalog_bucket_name" {
  description = "Catalog bucket name."
  value       = aws_s3_bucket.unity_catalog_bucket.bucket
}

output "workspace_catalog" {
  description = "Workspace catalog"
  value       = databricks_catalog.workspace_catalog
}

output "data_schemas" {
  description = "Data schemas"
  value       = databricks_schema.data_schemas
}