variable "aws_account_id" {
  type        = string
  description = "ID of the AWS account."
}

variable "aws_iam_partition" {
  type        = string
  description = "AWS partition to use for IAM ARNs and policies"
  default     = "aws"
}

variable "aws_assume_partition" {
  type        = string
  description = "AWS partition to use for assume role policies"
  default     = "aws"
}

variable "unity_catalog_iam_arn" {
  type        = string
  description = "Unity Catalog IAM ARN for the master role"
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}

variable "cmk_admin_arn" {
  description = "Amazon Resource Name (ARN) of the CMK admin."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the resource names."
  type        = string
}

variable "uc_catalog_name" {
  description = "UC catalog name created for the workspace."
  type        = string
}

variable "user_workspace_catalog_admin" {
  description = "Workspace catalog admin - same user as the account admin."
  type        = string
}

variable "workspace_id" {
  description = "workspace ID of deployed workspace."
  type        = string
}

variable "catalog_isolation_mode" {
  description = "Whether the catalog is accessible from all workspaces or a specific set of workspaces (ISOLATED or OPEN)"
  type        = string
  default     = "ISOLATED"
}