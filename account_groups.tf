# Define all groups configuration
locals {
  groups_config = {
    data_engineers = {
      display_name           = "data-engineers-wl"
      workspace_access       = true
      allow_cluster_create   = true
      databricks_sql_access  = true
    }
    analysts = {
      display_name          = "data-analysts-wl"
      workspace_access      = true
      databricks_sql_access = true
    }
    data_scientists = {
      display_name          = "data-scientists-wl"
      workspace_access      = true
      databricks_sql_access = true
    }
    product_managers = {
      display_name          = "product-managers-wl"
      workspace_access      = true
      databricks_sql_access = true
    }
    design = {
      display_name          = "design-wl"
      workspace_access      = true
      databricks_sql_access = true
    }
    backend = {
      display_name     = "backend-wl"
      workspace_access = true
    }
    metastore_admins = {
      display_name     = "metastore-admin-wl"
      workspace_access = true
    }
  }
}

# Create account-level groups using for_each
resource "databricks_group" "groups" {
  for_each = local.groups_config
  provider = databricks.mws
  
  display_name           = each.value.display_name
  workspace_access       = each.value.workspace_access
  allow_cluster_create   = try(each.value.allow_cluster_create, null)
  databricks_sql_access  = try(each.value.databricks_sql_access, null)
}

##assign admin user to metastore admins group 
data "databricks_user" "admin_user" {
  provider = databricks.mws
  user_name = var.admin_user
}

#assign sp to metastore admins group 
data "databricks_service_principal" "executor" {  
  provider = databricks.mws
  application_id = var.executor_application_id
}

resource "databricks_group_member" "metastore_admins_assign" {
  provider = databricks.mws
  group_id = databricks_group.groups["metastore_admins"].id
  member_id = data.databricks_service_principal.executor.id
}

resource "databricks_group_member" "metastore_admins_assign_admin_user" {
  provider = databricks.mws
  group_id = databricks_group.groups["metastore_admins"].id
  member_id = data.databricks_user.admin_user.id
}
