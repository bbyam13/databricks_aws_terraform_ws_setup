
# Create telemetry volume in the raw schema - maps to the telemetry data bucket prefix for the environment
locals {
  telemetry_storage_url = var.telemetry_bucket_name != null ? "s3://${var.telemetry_bucket_name}/${var.telemetry_bucket_env_prefix}" : null
}
resource "null_resource" "previous" {}

resource "time_sleep" "wait_120_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "120s"
}

// Storage Credential
resource "databricks_storage_credential" "telemetry_storage_credential" {
  name = "${var.resource_prefix}-telemetry-credential"
  aws_iam_role {
    role_arn = "arn:aws:iam::${var.aws_account_id}:role/${var.resource_prefix}-telemetry-credential"
  }
  force_update = true
  isolation_mode = "OPEN"
}

// Storage Credential Trust Policy
data "databricks_aws_unity_catalog_assume_role_policy" "telemetry_unity_catalog_assume_role_policy" {
  aws_account_id = var.aws_account_id
  role_name      = "${var.resource_prefix}-telemetry-credential"
  external_id    = databricks_storage_credential.telemetry_storage_credential.aws_iam_role[0].external_id
}

// Storage Credential Role
resource "aws_iam_role" "telemetry_storage_credential_role" {
  name               = "${var.resource_prefix}-telemetry-credential"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.telemetry_unity_catalog_assume_role_policy.json
  tags = {
    Name    = "${var.resource_prefix}-telemetry-credential"
    Project = var.resource_prefix
  }
}

# policy to allow the databricks workspace to access the telemetry data bucket + manage SNS + SQS for file events- json pulled from databricks provider
data "databricks_aws_unity_catalog_policy" "telemetry_unity_catalog_policy" {
  aws_account_id = var.aws_account_id
  bucket_name    = var.telemetry_bucket_name
  role_name      = "${var.resource_prefix}-telemetry-credential"
}

// Storage Credential Policy
resource "aws_iam_role_policy" "telemetry_storage_credential_policy" {
  name = "${var.resource_prefix}-telemetry-credential-policy"
  role = aws_iam_role.telemetry_storage_credential_role.id
  policy = data.databricks_aws_unity_catalog_policy.telemetry_unity_catalog_policy.json
}

#give time for the managed file event resources to be deleted before the role is deleted
resource "time_sleep" "wait_for_managed_file_event_resources_to_be_deleted" {
    destroy_duration = "60s"
    depends_on = [
      databricks_storage_credential.telemetry_storage_credential,
      aws_iam_role_policy.telemetry_storage_credential_policy,
      aws_iam_role.telemetry_storage_credential_role,
    ]
}

// External Location
resource "databricks_external_location" "telemetry_location" {
  name            = "external-location-telemetry-${var.resource_prefix}"
  url             = local.telemetry_storage_url
  credential_name = databricks_storage_credential.telemetry_storage_credential.id
  read_only       = true
  comment         = "Read only external location for ${local.telemetry_storage_url}"
  isolation_mode  = "OPEN"
  skip_validation = true
  enable_file_events = true
  file_event_queue {
    managed_sqs {} # databricks will create the SQS queue for file events
  }
  depends_on = [
    time_sleep.wait_120_seconds,
    time_sleep.wait_for_managed_file_event_resources_to_be_deleted,
  ]
}

// External Location Grant
resource "databricks_grants" "telemetry_location_grants" {
  external_location = databricks_external_location.telemetry_location.id
  grant {
    principal  = var.read_only_external_location_admin
    privileges = ["ALL_PRIVILEGES"]
  }
}