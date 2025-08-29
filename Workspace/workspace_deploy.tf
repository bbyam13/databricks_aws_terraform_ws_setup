# Define locals to configure deployment

locals {
  vpc_cidr = var.cidr_block
  root_bucket_name = "${var.env}-ws-root-bucket"
  prefix = "${var.env}"
  tags = {
    Owner = "${var.user_name}"
    Environment = "${var.env} PrivateLink Workspace"
    }
  force_destroy = true #destroy root bucket when deleting stack?
}

##Cross-Account IAM role
resource "aws_iam_role" "databricks_cross_account" {
  name = "${var.env}-databricks-cross-account-role-us-east"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::414351767826:root" # Databricks AWS Account ID (E2)
        },
        Action = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.databricks_account_id
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "databricks_permissions" {
  name        = "${var.env}-cross-account-role-us-east"
  description = "Permissions for Databricks to manage resources in target account"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1403287045000",
            "Effect": "Allow",
            "Action": [
                "ec2:AllocateAddress",
                "ec2:AssignPrivateIpAddresses",
                "ec2:AssociateDhcpOptions",
                "ec2:AssociateIamInstanceProfile",
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AttachVolume",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CancelSpotInstanceRequests",
                "ec2:CreateDhcpOptions",
                "ec2:CreateFleet",
                "ec2:CreateInternetGateway",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateLaunchTemplateVersion",
                "ec2:CreateNatGateway",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVolume",
                "ec2:CreateVpc",
                "ec2:CreateVpcEndpoint",
                "ec2:DeleteDhcpOptions",
                "ec2:DeleteFleets",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteLaunchTemplate",
                "ec2:DeleteLaunchTemplateVersions",
                "ec2:DeleteNatGateway",
                "ec2:DeleteRoute",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteTags",
                "ec2:DeleteVolume",
                "ec2:DeleteVpc",
                "ec2:DeleteVpcEndpoints",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeFleetHistory",
                "ec2:DescribeFleetInstances",
                "ec2:DescribeFleets",
                "ec2:DescribeIamInstanceProfileAssociations",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribeNatGateways",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribePrefixLists",
                "ec2:DescribeReservedInstancesOfferings",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSpotPriceHistory",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcAttribute",
                "ec2:DescribeVpcs",
                "ec2:DetachInternetGateway",
                "ec2:DisassociateIamInstanceProfile",
                "ec2:DisassociateRouteTable",
                "ec2:GetLaunchTemplateData",
                "ec2:GetSpotPlacementScores",
                "ec2:ModifyFleet",
                "ec2:ModifyLaunchTemplate",
                "ec2:ModifyVpcAttribute",
                "ec2:ReleaseAddress",
                "ec2:ReplaceIamInstanceProfileAssociation",
                "ec2:RequestSpotInstances",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupIngress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVpcs",
                "ec2:DescribeNetworkAcls",
                "ec2:DescribeVpcAttribute"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:PutRolePolicy"
            ],
            "Resource": "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "spot.amazonaws.com"
                }
            }
        }
    ]
})
}


resource "aws_iam_role_policy_attachment" "attach_permissions" {
  role       = aws_iam_role.databricks_cross_account.name
  policy_arn = aws_iam_policy.databricks_permissions.arn
}

# Enhanced wait time for IAM role propagation
resource "time_sleep" "wait_for_iam_role" {
  depends_on = [
    aws_iam_role.databricks_cross_account,
    aws_iam_role_policy_attachment.attach_permissions
  ]
  # IAM role propagation can sometimes take up to 60 seconds or more
  create_duration = "10s"
}

# Create S3 root bucket
resource "aws_s3_bucket" "this" {
  bucket = local.root_bucket_name

  force_destroy = local.force_destroy

  tags = merge(local.tags, {
    Name = local.root_bucket_name
  })
}

resource "aws_s3_bucket_ownership_controls" "root_bucket_oc" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "root_bucket_acls" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.root_bucket_oc]
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled"
  }
}


resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.this]
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject",
      "s3:GetObjectVersion",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:PutObject",
      "s3:DeleteObject"]
    resources = [
      "${aws_s3_bucket.this.arn}/*",
      aws_s3_bucket.this.arn]
    principals {
      identifiers = ["arn:aws:iam::${var.databricks_aws_account_id}:root"]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket     = aws_s3_bucket.this.id
  policy     = data.aws_iam_policy_document.this.json

  depends_on = [aws_s3_bucket_public_access_block.this]
}


# Create networking VPC resources

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.prefix
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names
  tags = local.tags

  enable_dns_hostnames = true

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  
  create_igw = true

  public_subnets = [cidrsubnet(local.vpc_cidr,3,0)]
  private_subnets = [cidrsubnet(local.vpc_cidr,3,1),
  cidrsubnet(local.vpc_cidr,3,2),
  cidrsubnet(local.vpc_cidr,3,3)
  ]
}

# Databricks Security Group
resource "aws_security_group" "databricks_sg" {
    
  vpc_id = module.vpc.vpc_id
  
  egress {
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
  egress {
            from_port = 3306
            to_port = 3306
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
  egress {
            from_port = 6666
            to_port = 6666
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
  egress {
            from_port = 9092
            to_port = 9098
            protocol = "tcp"
            cidr_blocks = [var.cidr_block]
        }

  egress {
            self = true
            from_port = 0
            to_port = 65535
            protocol = "tcp"
    }
  egress {
            self = true
            from_port = 0
            to_port = 65535
            protocol = "udp"
    }

  ingress {
            self = true
            from_port = 0
            to_port = 65535
            protocol = "tcp"
    }
  ingress {
            self = true
            from_port = 0
            to_port = 65535
            protocol = "udp"
    }

  tags = local.tags
}


# create service endpoints for AWS services
# S3 endpoint
resource "aws_vpc_endpoint" "s3" {
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_id = module.vpc.vpc_id
  route_table_ids = module.vpc.private_route_table_ids
  tags = local.tags
  vpc_endpoint_type = "Gateway"
}

# STS endpoint
resource "aws_vpc_endpoint" "sts" {
  service_name = "com.amazonaws.${var.region}.sts"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  tags = local.tags
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.databricks_sg.id]
  private_dns_enabled = true
}

# Databricks objects
resource "time_sleep" "wait" {
  depends_on = [aws_iam_role.databricks_cross_account]
  create_duration = "30s"
}


resource "databricks_mws_credentials" "this" {
  provider         = databricks.accounts
  role_arn         = aws_iam_role.databricks_cross_account.arn
  credentials_name = "${local.prefix}-creds"
  depends_on       = [time_sleep.wait_for_iam_role]
}

# resource "time_sleep" "wait" {
#   depends_on = [
#     aws_iam_role.cross_account_role
#   ]
#   create_duration = "10s"
# }

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.accounts
  account_id                 = var.databricks_account_id
  storage_configuration_name = "${local.prefix}-dbfs"
  bucket_name                = aws_s3_bucket.this.bucket

  depends_on = [aws_s3_bucket_policy.this]
}

resource "databricks_mws_networks" "this" {
  provider = databricks.accounts
  account_id = var.databricks_account_id
  network_name = "${local.prefix}-network"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  security_group_ids = [aws_security_group.databricks_sg.id]
}


resource "databricks_mws_workspaces" "this" {
  provider = databricks.accounts
  account_id = var.databricks_account_id
  workspace_name = "${var.env}-ws"
  # deployment_name = local.prefix
  #pricing_tier = "PREMIUM"
  aws_region = var.region

  credentials_id = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id = databricks_mws_networks.this.network_id
}

# Create job executor service principal for the workspace
resource "databricks_service_principal" "job_executor_sp" {
  provider     = databricks.workspace
  display_name = "${var.env}-job-executor-sp"
  active       = true
  
  depends_on = [databricks_mws_workspaces.this]
}

# Grant workspace admin permissions to the service principal
resource "databricks_mws_permission_assignment" "sp_workspace_admin" {
  provider       = databricks.accounts
  workspace_id   = databricks_mws_workspaces.this.workspace_id
  principal_id   = databricks_service_principal.job_executor_sp.id
  permissions    = ["ADMIN"]
}

# Output
output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "service_principal_application_id" {
  value = databricks_service_principal.job_executor_sp.application_id
  description = "Service principal application ID"
}