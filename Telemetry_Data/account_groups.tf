# Create account-level groups
data "databricks_group" "data_engineers" {
  provider = databricks.accounts
  display_name = "data-engineers-wl"
  workspace_access = true
  allow_cluster_create = true
  databricks_sql_access = true
}

data "databricks_group" "analysts" {
  provider = databricks.accounts
  display_name = "data-analysts-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "data_scientists" {
  provider = databricks.accounts
  display_name = "data-scientists-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "product_managers" {
  provider = databricks.accounts
  display_name = "product-managers-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "design" {
  provider = databricks.accounts
  display_name = "design-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "backend" {
  provider = databricks.accounts
  display_name = "backend-wl"
  workspace_access = true

}