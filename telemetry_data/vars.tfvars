databricks_account_id = "YOUR DATABRICKS ACCOUNT ID"
databricks_aws_account_id = "414351767826" # databricks aws account id
user_name = "Service Principal ID OR USERNAME"
region = "us-east-2" # region of the account

# existing workspace url that SP can access - required to create an external location for telemetry data
# workspace must be assigned to the Unity Catalog metastore created in Account_Level_Setup
workspace_url = "existing databricksworkspace url that SP can access"

# telemetry location name - will also be used as a prefix for assets created by terraform
telemetry_location_name = "telemetry-data"
telemetry_bucket_name = "telemetry-data-bucket" #name of your telemetry bucket