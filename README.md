# Databricks AWS Terraform Workspace Setup

This Terraform project automates the deployment of a complete Databricks environment on AWS, including account-level configuration and workspace deployment with Unity Catalog integration.

## Project Structure

The project is organized into two main terrafrom root modules: (1)account level setup and (2) workspace. The account-level setup creates foundational resources that will be used across workspaces - the Unity Catalog metastore and account groups. The workspace project deploys a workspace with a customer managed VPC along with an associated UC catalog with with multiple schemas and permissions for the account groups.

### 1. Account Level Setup (`Account_Level_Setup/`)

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
  - **Metastore Admin Group**: Assigned as metastore admin - ownsership and control over metastore created. 

#### `account_metastore.tf`
- **Purpose**: Creates the Unity Catalog metastore
- **Contents**:
  - Unity Catalog metastore resource configuration
  - Ownership assignment to specified user

#### `vars.tfvars`
- **Purpose**: Variable definitions file for account-level configuration
- **Contents**: Placeholder values for Databricks account ID, AWS account ID, username, and region

### 2. Workspace (`Workspace/`)

Deploys individual Databricks workspaces along with an associated UC catalog. The catalog is configured with multiple schemas and permissions for the account groups.

The workspace deployment creates a complete Databricks workspace with a customer managed VPC in AWS.


#### `workspace_deploy.tf`
- **Purpose**: Complete workspace infrastructure deployment
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

#### `catalog_location.tf`
- **Purpose**: Creates external storage location and credentials for Unity Catalog
- **Contents**:
  - **S3 Data Lake Bucket**: Dedicated bucket for data storage with security controls
  - **IAM Role for Data Access**: Secure role for Unity Catalog to access S3
  - **Storage Credential**: Databricks credential linked to IAM role
  - **External Location**: Unity Catalog external location pointing to S3 bucket
  - **Folder Structure**: Creates bronze/silver/gold/playground/reference/finance prefixes in s3 for each schema

#### `catalog_structure.tf`
- **Purpose**: Creates Unity Catalog structure with catalogs and schemas
- **Contents**:
  - **Metastore Assignment**: Links metastore to workspace
  - **Catalog**: Creates catalog for the workspace
  - **Data Schemas**: Creates schemas for each data layer (bronze, silver, gold, etc.) aligned with s3 prefixes

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

