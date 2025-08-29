# Databricks AWS Terraform Workspace Setup

This Terraform project automates the deployment of a Databricks environment on AWS including account-level configuration, telemetry data acesss from an existing S3 bucket, and workspace deployment with Unity Catalog integration.

## Project Structure

The project is organized into three main terraform root modules: (1) account level setup, (2) telemetry data, and (3) workspace. The account-level setup creates foundational resources that will be used across workspaces - the Unity Catalog metastore and account groups. The telemetry data module creates infrastructure for accessing telemetry data (existing s3 bucket) across workspaces with a Unity Catalog external location. The workspace project deploys a workspace with a customer managed VPC along with an associated UC catalog with multiple schemas and permissions for the account groups. It is desinged to handle deploying several workspaces within the same account using the same Unity Catalog metastore.

## Deployment Order

The modules have specific dependencies that require a particular deployment sequence. The telemetry data module requires an existing workspace to be deployed because external location creation uses workspace-level APIs.

### Step-by-Step Deployment Process

1. **Account Level Setup**
   ```bash
   cd Account_Level_Setup
   terraform apply -var-file="vars.tfvars"
   ```
   - Creates Unity Catalog metastore and account-level groups
   - Required by both workspace and telemetry data modules

2. **Initial Workspace Deployment (workspace)**
   - pass id of newly created metastore into the vars.tfvars 
   ```bash
   cd workspace
   terraform apply -var-file="devvars.tfvars"
   ```
   - Creates workspace with customer managed VPC and Unity Catalog integration. Will bypass the creation of the telemetry volume as external location doesn't exist.
   - Workspace functionality is fully operational without telemetry integration

3. **Telemetry Data (telemetry-data)** 
   - pass workspace url of newly created workspace into the vars.tfvars 
   ```bash
   cd telemetry_data
   terraform apply -var-file="vars.tfvars"
   ```
   - Creates external location for accessing existing telemetry S3 bucket
   - **Dependency**: Requires workspace to exist (external location creation is workspace-level API)
   - Enables Unity Catalog access to telemetry data across workspaces

4. **Reapply Initial Workspace (workspace)** 
   ```bash
   cd workspace
   terraform apply -var-file="devvars.tfvars"
   ```
   - Will detect newly created telemetry external location and creates telemetry volume
   - Integrates telemetry data access into workspace catalog structure

5. **Multi-Workspace Deployment (workspace)**
   - For additional workspaces sharing the same metastore and telemetry data, use the workspace module with environment-specific variable files
    ```bash
   cd workspace
   terraform apply -var-file="stagevars.tfvars"  # or prodvars.tfvars
   ```

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

### 2. Telemetry Data (`telemetry_data/`)

Creates the infrastructure for handling telemetry data with Unity Catalog integration, including external location setup and file event processing.

#### `telemetry_location.tf`
- **Purpose**: Creates external location and IAM infrastructure for telemetry data access
- **Contents**:
  - **IAM Role and Policy**: Secure role for Databricks to access telemetry S3 bucket
  - **Storage Credential**: Databricks credential linked to IAM role for S3 access
  - **External Location**: Unity Catalog external location pointing to telemetry S3 bucket
  - **File Events**: Enables automatic file event notifications with managed SQS queue
  - **S3 Bucket Integration**: References existing telemetry data bucket for external access

#### `main.tf`
- **Purpose**: Core terraform configuration for telemetry data module
- **Contents**:
  - Provider configuration for AWS and Databricks
  - Variable definitions for telemetry location and bucket configuration
  - Output values for workspace URL and integration details

#### `vars.tfvars`
- **Purpose**: Variable definitions file for telemetry data configuration
- **Contents**: Values for metastore ID, workspace URL, telemetry location name, and bucket configuration

### 3. Workspace (`Workspace/`)

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
  - **Folder Structure**: Creates bronze/silver/gold/playground/reference/finance/raw prefixes in S3 for each schema

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
  - **Raw Schema**: Full access to data engineers (raw telemetry and ingestion data)

#### `telemetry_volume.tf`
- **Purpose**: Creates Unity Catalog volumes for telemetry data integration
- **Contents**:
  - **External Telemetry Volume**: Maps to environment-specific telemetry data in S3
  - **Managed Telemetry Metadata Volume**: Stores checkpoint data, schemas, and processing metadata
  - **External Location Integration**: References telemetry external location created in telemetry_data module
  - **Conditional Creation**: Only creates volumes if telemetry external location exists

#### Variable Files
Use these to configure deployment of your workspaces. 

##### `devvars.tfvars`
- **Purpose**: Sample Development environment variable values

##### `prodvars.tfvars`
- **Purpose**: Sample Production environment variable values

