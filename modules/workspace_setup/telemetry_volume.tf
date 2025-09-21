resource "databricks_volume" "telemetry_volume" {
  count            = var.telemetry_bucket_name != null ? 1 : 0
  provider         = databricks.created_workspace
  name             = "telemetry"
  catalog_name     = module.unity_catalog_catalog_creation.workspace_catalog.name
  schema_name      = "raw"
  volume_type      = "EXTERNAL"
  storage_location = local.telemetry_storage_url
  comment          = "Telemetry data"
  depends_on = [
   module.telemetry_location
  ]
}

# Create telemetry metadata volume in the raw schema - store checkpoint data, schemas, etc. from the telemetry data
resource "databricks_volume" "telemetry_metadata_volume" {
  count            = var.telemetry_bucket_name != null ? 1 : 0
  provider         = databricks.created_workspace
  name             = "telemetry_metadata"
  catalog_name     = module.unity_catalog_catalog_creation.workspace_catalog.name
  schema_name      = "raw"
  volume_type      = "MANAGED" #will use the catalog's managed location for storage - see catalog_location.tf
  comment          = "Telemetry metadata"
  depends_on = [
    module.unity_catalog_metastore_assignment,
    module.unity_catalog_catalog_creation
  ]
}