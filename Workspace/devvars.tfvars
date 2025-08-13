databricks_account_id = "YOUR DATABRICKS ACCOUNT ID"
metastore_id = "YOUR METASTORE ID"
databricks_aws_account_id = "YOUR AWS ACCOUNT ID"
user_name = "YOUR USERNAME"
cidr_block = "10.10.0.0/16"
region = "us-east-2"
env = "dev"

### region's VPC endpoint service domains required for workspace to use AWS PrivateLink
## see regional endpoints here: https://docs.databricks.com/aws/en/resources/ip-domain-region#privatelink-vpc-endpoint-services.
private_link_service_relay = "com.amazonaws.vpce.us-east-2.vpce-svc-090a8fab0d73e39a6" #SCC secure cluster connectivity relay
private_link_service_workspace = "com.amazonaws.vpce.us-east-2.vpce-svc-041dc2b4d7796b8d3" #the rest API
