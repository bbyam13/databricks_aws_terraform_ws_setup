metastore_id = "YOUR METASTORE ID"
databricks_account_id = "YOUR DATABRICKS ACCOUNT ID"
databricks_aws_account_id = "414351767826" # databricks aws account id
user_name = "YOUR USERNAME OR SERVICE PRINCIPAL ID"
cidr_block = "10.10.0.0/16"
region = "us-east-2"

# workspace name
env = "dev"

#maps to the telemetry bucket prefix for each environment
#specifices which environment's telemetry data will be accessible in the workspace's telemetry volume
telemetry_bucket_env_prefix = "dev" 

#telemetry external location name created in telemetry_data
telemetry_location_name = "telemetry-data"
