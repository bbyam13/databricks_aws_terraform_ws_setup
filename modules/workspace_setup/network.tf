# EXPLANATION: Create the customer managed-vpc and security group rules

# Data source for S3 Prefix List
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.region}.s3"
}

# VPC and other assets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "${var.resource_prefix}-classic-compute-plane-vpc"
  cidr = var.vpc_cidr_range
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)  # Use only first 2 AZs to match subnet config

  enable_dns_hostnames   = true
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  create_igw             = true

  private_subnet_names = [for az in data.aws_availability_zones.available.names : format("%s-private-%s", var.resource_prefix, az)]
  private_subnets      = var.private_subnets_cidr

  public_subnet_names = [for az in data.aws_availability_zones.available.names : format("%s-public-%s", var.resource_prefix, az)]
  public_subnets      = var.public_subnets_cidr

  tags = {
    Project = var.resource_prefix
  }
}


# Security group - skipped in custom mode
resource "aws_security_group" "sg" {
  name   = "${var.resource_prefix}-workspace-sg"
  vpc_id = module.vpc.vpc_id


  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = ingress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = egress.value
      self        = true
    }
  }

  # Open Egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "S3 Gateway Endpoint - SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_prefix_list.s3.id]
  }

  tags = {
    Name    = "${var.resource_prefix}-workspace-sg"
    Project = var.resource_prefix
  }
  depends_on = [module.vpc]
}