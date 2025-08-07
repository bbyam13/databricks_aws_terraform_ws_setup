resource "databricks_metastore" "this" {
  provider = databricks.accounts
  name          = "demo-metastore"
  owner         = var.user_name
  region        = "us-east-1"
  force_destroy = true
}

# Add a delay to ensure metastore is fully created
resource "time_sleep" "wait_for_metastore" {
  depends_on = [databricks_metastore.this]
  create_duration = "30s"
}

