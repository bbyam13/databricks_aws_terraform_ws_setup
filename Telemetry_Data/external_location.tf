data "aws_caller_identity" "current" {}

locals {
    uc_iam_role = "${var.location_name}-access-role"
}

# grab existing S3 bucket 
data "aws_s3_bucket" "bucket" {
  bucket = "${var.s3_bucket_name}"
}

data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = local.uc_iam_role
  external_id    = databricks_storage_credential.storage_credential.aws_iam_role[0].external_id
}

data "databricks_aws_unity_catalog_policy" "this" {
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = data.aws_s3_bucket.bucket.bucket
  role_name      = local.uc_iam_role
}

resource "aws_iam_policy" "external_data_access" {
  policy = data.databricks_aws_unity_catalog_policy.this.json
  tags = merge({
    Name = "${var.location_name}-unity-catalog external access IAM policy"
  })
}

# Create a policy for managed file events - allows file notification mode with autoloader
data "aws_iam_policy_document" "managed_file_events" {
  statement {
    sid    = "ManagedFileEventsSetupStatement"
    effect = "Allow"

    actions = [
      "s3:GetBucketNotification",
      "s3:PutBucketNotification",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:CreateTopic",
      "sns:TagResource",
      "sns:Publish",
      "sns:Subscribe",
      "sqs:CreateQueue",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue",
      "sqs:ChangeMessageVisibility",
      "sqs:PurgeQueue",
    ]

    resources = [
      data.aws_s3_bucket.bucket.arn,
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*",
    ]
  }

  statement {
    sid    = "ManagedFileEventsListStatement"
    effect = "Allow"

    actions = [
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sns:ListTopics",
    ]

    resources = [
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*",
    ]
  }

  statement {
    sid    = "ManagedFileEventsTeardownStatement"
    effect = "Allow"

    actions = [
      "sns:Unsubscribe",
      "sns:DeleteTopic",
      "sqs:DeleteQueue",
    ]

    resources = [
      "arn:aws:sqs:*:*:csms-*",
      "arn:aws:sns:*:*:csms-*",
    ]
  }
}

resource "aws_iam_policy" "managed_file_events_access" {
  policy = data.aws_iam_policy_document.managed_file_events.json
  tags = merge({
    Name = "${var.location_name}-managed file events access IAM policy"
  })
}

# Create a dedicated IAM role for bucket access
resource "aws_iam_role" "access_role" {
  name = "${var.location_name}-access-role"
  
  # Add a description for better documentation
  description = "Role for accessing the telemetry data bucket"
  assume_role_policy = data.databricks_aws_unity_catalog_assume_role_policy.this.json
  tags = {
    Name = "${var.location_name} Access Role"
  }
}

resource "aws_iam_role_policy_attachment" "access_role_policy_attachment_managed_file_events" {
  role       = aws_iam_role.access_role.name
  policy_arn = aws_iam_policy.managed_file_events_access.arn
  depends_on = [aws_iam_role.access_role]
}

resource "aws_iam_role_policy_attachment" "access_role_policy_attachment" {
  role       = aws_iam_role.access_role.name
  policy_arn = aws_iam_policy.external_data_access.arn
  depends_on = [aws_iam_role.access_role]
}

# create a storage credential 
resource "databricks_storage_credential" "storage_credential" {
  provider = databricks.workspace
  name = "${var.location_name}-credential"
  //cannot reference aws_iam_role directly, as it will create circular dependency
  aws_iam_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.uc_iam_role}"
  }
  comment = "Managed by TF"
  force_destroy = true
}

# Create external location for the S3 bucket
resource "databricks_external_location" "location" {
  provider        = databricks.workspace
  name            = "${var.location_name}"
  url             = "s3://${data.aws_s3_bucket.bucket.bucket}"
  credential_name = databricks_storage_credential.storage_credential.id
  comment         = "External location for telemetry data"
  read_only       = true
  force_destroy   = true
  skip_validation = true
  depends_on = [
    databricks_storage_credential.storage_credential,
    data.aws_s3_bucket.bucket,
    aws_iam_role_policy_attachment.access_role_policy_attachment
  ]
}

# External location access to groups
resource "databricks_grants" "location_access" {
  provider          = databricks.workspace
  external_location = databricks_external_location.location.id
  grant {
    principal  = data.databricks_group.data_engineers.display_name
    privileges = ["READ_FILES"]
  }
}

