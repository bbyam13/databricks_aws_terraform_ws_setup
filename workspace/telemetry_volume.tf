data "databricks_external_location" "telemetry_data_external_location" {
  count  = var.telemetry_location_name == null ? 0 : 1 # only run if the external location exists
  provider = databricks.created_workspace
  name = "${var.telemetry_location_name}"
  depends_on = [
      module.databricks_mws_workspace, 
      module.unity_catalog_metastore_assignment
  ]
}

locals {
  telemetry_storage_url = var.telemetry_location_name != null ? "s3://${var.telemetry_bucket_name}/${var.telemetry_bucket_env_prefix}" : "placeholder"
}

# Create telemetry volume in the raw schema - maps to the telemetry data bucket prefix for the environment
resource "databricks_volume" "telemetry_volume" {
  count  = var.telemetry_location_name == null ? 0 : 1 # only run if the external location exists
  provider         = databricks.created_workspace
  name             = "telemetry"
  catalog_name     = module.unity_catalog_catalog_creation.workspace_catalog.name
  schema_name      = "raw"
  volume_type      = "EXTERNAL"
  storage_location = local.telemetry_storage_url
  comment          = "Telemetry data"
  depends_on = [
   module.unity_catalog_metastore_assignment,
   data.databricks_external_location.telemetry_data_external_location, module.unity_catalog_catalog_creation, module.databricks_mws_workspace
  ]
}

# Create telemetry metadata volume in the raw schema - store checkpoint data, schemas, etc. from the telemetry data
resource "databricks_volume" "telemetry_metadata_volume" {
  provider         = databricks.created_workspace
  name             = "telemetry_metadata"
  catalog_name     = module.unity_catalog_catalog_creation.workspace_catalog.name
  schema_name      = "raw"
  volume_type      = "MANAGED" #will use the catalog's managed location for storage - see catalog_location.tf
  comment          = "Telemetry metadata"
  depends_on = [
    module.restrictive_root_bucket,
    databricks_grants.raw_access,
    module.unity_catalog_metastore_assignment,
    data.databricks_external_location.telemetry_data_external_location, module.unity_catalog_catalog_creation, module.databricks_mws_workspace
  ]
}

output "telemetry_volume_status" {
  value = var.telemetry_location_name != null ? "Telemetry volume created" : "Telemetry volume was not created. Please create the external location first, and then run again."
}