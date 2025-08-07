# Assign all groups to the workspace
resource "databricks_mws_permission_assignment" "data_engineers_workspace" {
  provider = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.data_engineers.id
  permissions = ["ADMIN"]
}

resource "databricks_mws_permission_assignment" "analysts_workspace" {
  provider = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.analysts.id
  permissions = ["USER"]
}

resource "databricks_mws_permission_assignment" "data_scientists_workspace" {
  provider = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.data_scientists.id
  permissions = ["USER"]
}

resource "databricks_mws_permission_assignment" "product_managers_workspace" {
  provider = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.product_managers.id
  permissions = ["USER"]
}

resource "databricks_mws_permission_assignment" "design_workspace" {
  provider = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.design.id
  permissions = ["USER"]
}

resource "databricks_mws_permission_assignment" "backend_workspace" {
  provider = databricks.accounts
  workspace_id = databricks_mws_workspaces.this.workspace_id
  principal_id = data.databricks_group.backend.id
  permissions = ["USER"]
}
