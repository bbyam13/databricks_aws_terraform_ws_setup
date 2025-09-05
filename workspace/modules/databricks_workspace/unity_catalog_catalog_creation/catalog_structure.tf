# Create folder-like prefixes in S3 by uploading empty objects
locals {
  prefixes = ["bronze", "silver", "gold", "playground", "reference", "finance", "raw"]
}

# Create schemas matching the prefixes
resource "databricks_schema" "data_schemas" {
  for_each = toset(local.prefixes)
  name         = each.key
  catalog_name = databricks_catalog.workspace_catalog.name
  comment      = "${each.key} schema for ${var.resource_prefix} environment"
  properties = {
    kind = each.key
  }
  storage_root = "s3://${aws_s3_bucket.unity_catalog_bucket.bucket}/${each.key}/"
  depends_on = [databricks_catalog.workspace_catalog]
}


