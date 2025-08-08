resource "databricks_metastore" "this" {
  provider = databricks.accounts
  name          = "wldemo-metastore"
  owner         = var.user_name #this should be the user/service principal executing the terraform
  region        = var.region
  force_destroy = true
}

# Add a delay to ensure metastore is fully created
resource "time_sleep" "wait_for_metastore" {
  depends_on = [databricks_metastore.this]
  create_duration = "30s"
}

output "metastore_id" {
  value = databricks_metastore.this.id
  description = "Unity Catalog metastore ID"
}

