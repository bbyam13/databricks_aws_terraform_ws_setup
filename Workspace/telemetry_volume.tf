data "databricks_external_location" "telemetry_data_external_location" {
  provider = databricks.workspace
  name = "${var.telemetry_location_name}"
  depends_on = [
    databricks_mws_workspaces.this
  ]

}

locals {
  create_telemetry_volume = length(data.databricks_external_location.telemetry_data_external_location.external_location_info) > 0
  telemetry_storage_url = local.create_telemetry_volume ? "${data.databricks_external_location.telemetry_data_external_location.external_location_info[0].url}${var.telemetry_bucket_env_prefix}" : "placeholder"
}

# Create telemetry volume in the raw schema - maps to the telemetry data bucket prefix for the environment
resource "databricks_volume" "telemetry_volume" {
  count = local.create_telemetry_volume ? 1 : 0 #CREATE Volume IF THE TELEMETRY DATA EXTERNAL LOCATION EXISTS 
  provider         = databricks.workspace
  name             = "telemetry"
  catalog_name     = databricks_catalog.env_catalog.name
  schema_name      = databricks_schema.data_schemas["raw"].name
  volume_type      = "EXTERNAL"
  storage_location = local.telemetry_storage_url
  comment          = "Telemetry data"
  depends_on = [
    data.databricks_external_location.telemetry_data_external_location
  ]
}

# Create telemetry metadata volume in the raw schema - store checkpoint data, schemas, etc. from the telemetry data
resource "databricks_volume" "telemetry_metadata_volume" {
  provider         = databricks.workspace
  name             = "telemetry_metadata"
  catalog_name     = databricks_catalog.env_catalog.name
  schema_name      = databricks_schema.data_schemas["raw"].name
  volume_type      = "MANAGED" #will use the catalog's managed location for storage - see catalog_location.tf
  comment          = "Telemetry metadata"
}

output "telemetry_volume_status" {
  value = local.create_telemetry_volume ? "Telemetry volume created" : "Telemetry volume was not created. Please create the external location first, and then run again."
}