# Databricks AWS Terraform Workspace Setup

This Terraform project automates the deployment of a complete Databricks environment on AWS, including account-level configuration and workspace deployment with Unity Catalog integration. The setup follows Databricks best practices for enterprise-grade deployments with proper security, networking, and data governance.


## Project Structure

The project is organized into two main deployment phases:

### 1. AWS Account Level Setup (`AWS_Account_Level_Setup/`)

The account-level setup creates foundational resources that will be used across workspaces - the Unity Catalog metastore and account groups

#### `account_groups.tf`
- **Purpose**: Creates account-level user groups
- **Contents**:
  - **Data Engineers Group**: Full workspace access with cluster creation privileges
  - **Data Analysts Group**: Workspace and SQL access for analysis tasks
  - **Data Scientists Group**: Workspace and SQL access for ML/analytics work
  - **Product Managers Group**: Workspace and SQL access for business insights
  - **Design Group**: Workspace and SQL access for design-related analytics
  - **Backend Group**: Workspace access for backend development teams

#### `account_metastore.tf`
- **Purpose**: Creates the Unity Catalog metastore
- **Contents**:
  - Unity Catalog metastore resource configuration
  - Ownership assignment to specified user

#### `vars.tfvars`
- **Purpose**: Variable definitions file for account-level configuration
- **Contents**: Placeholder values for Databricks account ID, AWS account ID, username, and region

### 2. AWS Workspace (`AWS_Workspace/`)

Deploys individual Databricks workspaces along with an associated UC catalog. The catalog is configured with multiple schemas and permissions for the account groups.

The workspace deployment creates a complete Databricks workspace with networking, storage, and data governance components.


#### `workspace_deploy.tf`
- **Purpose**: Complete workspace infrastructure deployment (573 lines of comprehensive setup)
- **Contents**:
  - **Cross-Account IAM Role**: Allows Databricks to manage AWS resources
  - **S3 Root Bucket**: DBFS root storage with proper security configuration
  - **VPC and Networking**: Complete network setup with public/private subnets
  - **Security Groups**: Databricks-specific security group rules
  - **VPC Endpoints**: S3, Kinesis, and STS endpoints for secure communication
  - **PrivateLink Setup**: Secure connectivity between Databricks and AWS
  - **Databricks Workspace**: Complete workspace creation with all dependencies

#### `workspace_groups.tf`
- **Purpose**: Assigns account-level groups to the workspace with appropriate permissions
- **Contents**:
  - Data Engineers: ADMIN permissions
  - All other groups: USER permissions
  - Permission assignments linking account groups to workspace access

#### `account_groups.tf`
- **Purpose**: Data source references to account-level groups
- **Contents**: Data source blocks that reference the groups created in account-level setup

#### `catalog_location.tf`
- **Purpose**: Creates external storage location and credentials for Unity Catalog
- **Contents**:
  - **S3 Data Lake Bucket**: Dedicated bucket for data storage with security controls
  - **IAM Role for Data Access**: Secure role for Unity Catalog to access S3
  - **Storage Credential**: Databricks credential linked to IAM role
  - **External Location**: Unity Catalog external location pointing to S3 bucket
  - **Folder Structure**: Creates bronze/silver/gold/playground/reference/finance prefixes

#### `catalog_structure.tf`
- **Purpose**: Creates Unity Catalog structure with catalogs and schemas
- **Contents**:
  - **Metastore Assignment**: Links metastore to workspace
  - **Environment Catalog**: Creates catalog named after environment (dev/prod)
  - **Data Schemas**: Creates schemas for each data layer (bronze, silver, gold, etc.)

#### `catalog_permissions.tf`
- **Purpose**: Implements role-based access control for Unity Catalog resources
- **Contents**:
  - **Catalog Access**: Grants USE_CATALOG to all groups
  - **Bronze Schema**: Full access only to data engineers (data ingestion layer)
  - **Silver Schema**: Full access to all groups (cleaned/processed data)
  - **Gold Schema**: Full access to all groups (business-ready data)
  - **Reference Schema**: Full access to all groups (reference/lookup data)

#### Variable Files
Use these to configure deployment of your workspaces. 

##### `devvars.tfvars`
- **Purpose**: Sample Development environment variable values

##### `prodvars.tfvars`
- **Purpose**: Sample Production environment variable values


## Security Features

- PrivateLink connectivity for secure communication
- IAM roles with least-privilege access
- S3 bucket encryption and access controls
- VPC with proper subnet segmentation
- Security groups with minimal required access

## Data Architecture

The setup implements a medallion architecture with:
- **Bronze**: Raw data ingestion (data engineers only)
- **Silver**: Cleaned and validated data (all users)
- **Gold**: Business-ready aggregated data (all users)
- **Playground**: Experimental data space
- **Reference**: Lookup and reference data
- **Finance**: Finance-specific data structures
