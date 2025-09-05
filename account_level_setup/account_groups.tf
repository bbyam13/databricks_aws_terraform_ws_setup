# Create account-level groups
resource "databricks_group" "data_engineers" {
  provider = databricks.accounts
  display_name = "data-engineers-wl"
  workspace_access = true
  allow_cluster_create = true
  databricks_sql_access = true
}

resource "databricks_group" "analysts" {
  provider = databricks.accounts
  display_name = "data-analysts-wl"
  workspace_access = true
  databricks_sql_access = true
}

resource "databricks_group" "data_scientists" {
  provider = databricks.accounts
  display_name = "data-scientists-wl"
  workspace_access = true
  databricks_sql_access = true
}

resource "databricks_group" "product_managers" {
  provider = databricks.accounts
  display_name = "product-managers-wl"
  workspace_access = true
  databricks_sql_access = true
}

resource "databricks_group" "design" {
  provider = databricks.accounts
  display_name = "design-wl"
  workspace_access = true
  databricks_sql_access = true
}

resource "databricks_group" "backend" {
  provider = databricks.accounts
  display_name = "backend-wl"
  workspace_access = true

}

resource "databricks_group" "metastore_admins" {
  provider = databricks.accounts
  display_name = "metastore-admin-wl"
  workspace_access = true
}

##assign user/sp to metastore admins group 
data "databricks_service_principal" "executor" {
  provider = databricks.accounts
  application_id = var.user_name
}
resource "databricks_group_member" "metastore_admins_assign" {
  provider = databricks.accounts
  group_id = databricks_group.metastore_admins.id
  member_id = data.databricks_service_principal.executor.id
}