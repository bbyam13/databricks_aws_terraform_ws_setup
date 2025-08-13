# General Catalog access to groups
resource "databricks_grants" "catalog_access" {
  provider = databricks.workspace
  catalog  = databricks_catalog.env_catalog.name
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
  provider = databricks.workspace
  schema   = databricks_schema.data_schemas["bronze"].id
  grant { 
  principal  = data.databricks_group.data_engineers.display_name
  privileges = ["ALL_PRIVILEGES"]
  }
}

resource "databricks_grants" "silver" {
  provider = databricks.workspace
  schema   = databricks_schema.data_schemas["silver"].id
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
  provider = databricks.workspace
  schema   = databricks_schema.data_schemas["gold"].id
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
  provider = databricks.workspace
  schema   = databricks_schema.data_schemas["reference"].id
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

# # Grant read and usage access to silver for all groups
# resource "databricks_grants" "silver" {
#   provider = databricks.workspace
#   catalog  = databricks_catalog.env_catalog.name
#   schema   = databricks_schema.data_schemas["silver"].name
#   grant {
#     principal  = data.databricks_group.data_engineers.display_name
#     privileges = ["ALL PRIVILEGES"]
#   }
#   grant {
#     principal  = data.databricks_group.analysts.display_name
#     privileges = ["SELECT"]
#   }
#   grant {
#     principal  = data.databricks_group.data_scientists.display_name
#     privileges = ["SELECT"]
#   }
#   grant {
#     principal  = data.databricks_group.product_managers.display_name
#     privileges = ["SELECT"]
#   }
#   grant {
#     principal  = data.databricks_group.design.display_name
#     privileges = ["SELECT"]
#   }
#   grant {
#     principal  = data.databricks_group.backend.display_name
#     privileges = ["SELECT"]
#   }
# }


