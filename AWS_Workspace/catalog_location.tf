data "aws_caller_identity" "current" {}

locals {
    uc_iam_role = "${var.env}-bluejay-access-role"
}

# create a storage credential 
resource "databricks_storage_credential" "bluejay_credential" {
  provider = databricks.workspace
  name = "${var.env}-bluejay-credential"
  //cannot reference aws_iam_role directly, as it will create circular dependency
  aws_iam_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.uc_iam_role}"
  }
  comment = "Managed by TF"
  force_destroy = true
  depends_on = [databricks_mws_workspaces.this, databricks_metastore_assignment.this]
}

# Create a new S3 bucket with prefixes for data layers
resource "aws_s3_bucket" "bluejay_bucket" {
  bucket        = "bluejay-${var.env}"
  force_destroy = true

  tags = {
    Name        = "${var.env} Bluejay Data Lake"
    Environment = var.env
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "bluejay_bucket_block" {
  bucket = aws_s3_bucket.bluejay_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create folder-like prefixes in S3 by uploading empty objects
locals {
  prefixes = ["bronze", "silver", "gold", "playground", "reference", "finance"]
}

resource "aws_s3_object" "prefixes" {
  for_each = toset(local.prefixes)

  bucket = aws_s3_bucket.bluejay_bucket.bucket
  key    = "${each.key}/"
  source = "/dev/null"
  etag   = filemd5("/dev/null") # Required to avoid lifecycle errors with /dev/null

  depends_on = [aws_s3_bucket.bluejay_bucket]
}

data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = local.uc_iam_role
  external_id    = databricks_storage_credential.bluejay_credential.aws_iam_role[0].external_id
}

data "databricks_aws_unity_catalog_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = aws_s3_bucket.bluejay_bucket.bucket
  role_name      = local.uc_iam_role
}

resource "aws_iam_policy" "external_data_access" {
  policy = data.databricks_aws_unity_catalog_policy.this.json
  tags = merge({
    Name = "${local.prefix}-unity-catalog external access IAM policy"
  })
}

# Create a dedicated IAM role for Bluejay bucket access
resource "aws_iam_role" "bluejay_access_role" {
  name = "${var.env}-bluejay-access-role"
  
  # Add a description for better documentation
  description = "Role for accessing the Bluejay data lake bucket in ${var.env} environment"
  assume_role_policy  = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  tags = {
    Name        = "${var.env} Bluejay Access Role"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "bluejay_access_role_policy_attachment" {
  role       = aws_iam_role.bluejay_access_role.name
  policy_arn = aws_iam_policy.external_data_access.arn
  depends_on = [aws_iam_role.bluejay_access_role]
}

# Create external location for the S3 bucket
resource "databricks_external_location" "bluejay_location" {
  provider = databricks.workspace
  name            = "bluejay_${var.env}_location"
  url             = "s3://${aws_s3_bucket.bluejay_bucket.bucket}"
  credential_name = databricks_storage_credential.bluejay_credential.id
  comment         = "External location for ${var.env} Bluejay data lake"
  force_destroy = true
  skip_validation = true
  depends_on = [
    databricks_storage_credential.bluejay_credential,
    aws_s3_bucket.bluejay_bucket,
    aws_iam_role_policy_attachment.bluejay_access_role_policy_attachment
  ]
}


# # Output important information
# output "bluejay_bucket_name" {
#   description = "The name of the created Bluejay S3 bucket"
#   value       = aws_s3_bucket.bluejay_bucket.bucket
# }

# output "bluejay_access_role_arn" {
#   description = "ARN of the IAM role for accessing the Bluejay bucket"
#   value       = aws_iam_role.bluejay_access_role.arn
# }

# output "catalog_name" {
#   description = "Name of the created Unity Catalog catalog"
#   value       = databricks_catalog.env_catalog.name
# }

# output "schemas" {
#   description = "List of created schemas"
#   value       = [for schema in databricks_schema.data_schemas : schema.name]
# }
