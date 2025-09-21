resource "databricks_metastore" "this" {
  provider = databricks.mws
  name          = var.metastore_name
  owner         = databricks_group.groups["metastore_admins"].display_name
  region        = var.region
  force_destroy = true
}

# Add a delay to ensure metastore is fully created
resource "time_sleep" "wait_for_metastore" {
  depends_on      = [databricks_metastore.this]
  create_duration = "30s"
}
