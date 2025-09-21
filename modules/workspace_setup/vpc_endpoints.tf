# EXPLANATION: VPC Gateway Endpoint for S3, Interface Endpoint for Kinesis, and Interface Endpoint for STS
# VPC endpoint creation - Skipped in custom operation mode
module "vpc_endpoints" {
  
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "3.11.0"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [aws_security_group.sg.id]

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name    = "${var.resource_prefix}-s3-vpc-endpoint"
        Project = var.resource_prefix
      }
    },
    sts = {
      service             = "sts"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name    = "${var.resource_prefix}-sts-vpc-endpoint"
        Project = var.resource_prefix
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      tags = {
        Name    = "${var.resource_prefix}-kinesis-vpc-endpoint"
        Project = var.resource_prefix
      }
    }
  }
}