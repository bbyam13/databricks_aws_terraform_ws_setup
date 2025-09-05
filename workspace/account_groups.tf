# Create account-level groups
data "databricks_group" "data_engineers" {
  provider = databricks.mws
  display_name = "data-engineers-wl"
  workspace_access = true
  allow_cluster_create = true
  databricks_sql_access = true
}

data "databricks_group" "analysts" {
  provider = databricks.mws
  display_name = "data-analysts-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "data_scientists" {
  provider = databricks.mws
  display_name = "data-scientists-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "product_managers" {
  provider = databricks.mws
  display_name = "product-managers-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "design" {
  provider = databricks.mws
  display_name = "design-wl"
  workspace_access = true
  databricks_sql_access = true
}

data "databricks_group" "backend" {
  provider = databricks.mws
  display_name = "backend-wl"
  workspace_access = true

}