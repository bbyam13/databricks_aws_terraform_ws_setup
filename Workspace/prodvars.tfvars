metastore_id = "METASTORE ID CREATED IN ACCOUNT LEVEL SETUP"
databricks_account_id = "DATABRICKS ACCOUNT ID"
databricks_aws_account_id = "DatabricksAWS ACCOUNT ID"
user_name = "YOUR USERNAME"
cidr_block = "10.10.0.0/16"
region = "us-east-1"
env = "prod"

## region's VPC endpoint service domains required for workspace to use AWS PrivateLink
## see regional endpoints here: https://docs.databricks.com/aws/en/resources/ip-domain-region#privatelink-vpc-endpoint-services.
private_link_service_relay = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6" #SCC secure cluster connectivity relay
private_link_service_workspace = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3" #the rest API
