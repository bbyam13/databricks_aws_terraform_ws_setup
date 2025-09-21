# Authenticate using environment variables: https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-envvars.html
# export AWS_ACCESS_KEY_ID=KEY_ID
# export AWS_SECRET_ACCESS_KEY=SECRET_KEY
# export AWS_SESSION_TOKEN=SESSION_TOKEN

provider "aws" {
  region = var.region
}

# Authenticate using environment variables: https://registry.terraform.io/providers/databricks/databricks/latest/docs#argument-reference
# export DATABRICKS_CLIENT_ID=CLIENT_ID
# export DATABRICKS_CLIENT_SECRET=CLIENT_SECRET

provider "databricks" {
  alias      = "mws"
  host       = local.computed_databricks_provider_host
  account_id = var.databricks_account_id
}


#workspace specific providers
provider "databricks" {
  alias      = "dev_workspace"
  host       = module.dev_workspace.databricks_host #this must match the module name
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias      = "uat_workspace"
  host       = module.uat_workspace.databricks_host #this must match the module name
  account_id = var.databricks_account_id
}