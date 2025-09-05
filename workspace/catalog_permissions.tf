# General Catalog access to groups
resource "databricks_grants" "catalog_access" {
 provider = databricks.created_workspace
  catalog  = module.unity_catalog_catalog_creation.workspace_catalog.name
  grant {
    principal  = data.databricks_group.data_engineers.display_name
    privileges = ["USE_CATALOG"]
  }
  grant {
    principal  = data.databricks_group.analysts.display_name
    privileges = ["USE_CATALOG"]
  }
  grant {
    principal  = data.databricks_group.data_scientists.display_name
    privileges = ["USE_CATALOG"]
  }
  grant {
    principal  = data.databricks_group.product_managers.display_name
    privileges = ["USE_CATALOG"]
  }
  grant {
    principal  = data.databricks_group.design.display_name
    privileges = ["USE_CATALOG"]
  }
  grant {
    principal  = data.databricks_group.backend.display_name
    privileges = ["USE_CATALOG", "MANAGE"]
  }
}

# Grant read and usage access to bronze for data engineers
resource "databricks_grants" "bronze" {
 provider = databricks.created_workspace
  schema   = module.unity_catalog_catalog_creation.data_schemas["bronze"].id
  grant { 
  principal  = data.databricks_group.data_engineers.display_name
  privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "silver" {
  provider = databricks.created_workspace
  schema   = module.unity_catalog_catalog_creation.data_schemas["silver"].id
  grant { 
  principal  = data.databricks_group.data_engineers.display_name
  privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.analysts.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.data_scientists.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.product_managers.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.design.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.backend.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "gold" {
  provider = databricks.created_workspace
  schema   = module.unity_catalog_catalog_creation.data_schemas["gold"].id
  grant { 
  principal  = data.databricks_group.data_engineers.display_name
  privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.analysts.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.data_scientists.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.product_managers.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.design.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.backend.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "reference" {
  provider = databricks.created_workspace
  schema   = module.unity_catalog_catalog_creation.data_schemas["reference"].id
  grant { 
  principal  = data.databricks_group.data_engineers.display_name
  privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.analysts.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.data_scientists.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.product_managers.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.design.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
  grant {
    principal  = data.databricks_group.backend.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}

# Grant full access to the raw schema to data engineers
resource "databricks_grants" "raw_access" {
  provider = databricks.created_workspace
  schema   = module.unity_catalog_catalog_creation.data_schemas["raw"].id
  grant {
    principal  = data.databricks_group.data_engineers.display_name
    privileges = ["ALL_PRIVILEGES"]
  }
}