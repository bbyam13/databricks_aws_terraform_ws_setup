# Assign the metastore to the workspace
resource "databricks_metastore_assignment" "this" {
  provider = databricks.accounts
  metastore_id = "${var.metastore_id}"
  workspace_id = databricks_mws_workspaces.this.workspace_id
  depends_on = [databricks_mws_workspaces.this]
}

# Add a delay to ensure metastore is assigned to the workspace before adding permissions
resource "time_sleep" "wait_for_metastore_assignment" {
  create_duration = "60s"
  depends_on = [databricks_metastore_assignment.this]
}

# Create a catalog named after the environment
resource "databricks_catalog" "env_catalog" {
  provider = databricks.workspace
  name         = "${var.env}-catalog"
  comment      = "Catalog for ${var.env} environment"
  properties = {
    purpose = "Data for ${var.env} environment"
  }
  storage_root = "s3://${aws_s3_bucket.x_bucket.bucket}/"
  depends_on = [
    databricks_external_location.x_location,
    time_sleep.wait_for_metastore_assignment
  ]
}

# Create schemas matching the prefixes
resource "databricks_schema" "data_schemas" {
  for_each = toset(local.prefixes)
  
  provider     = databricks.workspace
  name         = each.key
  catalog_name = databricks_catalog.env_catalog.name
  comment      = "${each.key} schema for ${var.env} environment"
  properties = {
    kind = each.key
  }
  storage_root = "s3://${aws_s3_bucket.x_bucket.bucket}/${each.key}/"
  depends_on = [databricks_catalog.env_catalog, time_sleep.wait_for_metastore_assignment]
}


