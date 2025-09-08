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

2. **Initial Workspace SRA Deployment (workspace)**
   - Pass id of newly created metastore into the devvars.tfvars 
   - Set `telemetry_location_name = null` in devvars.tfvars for initial deployment
   ```bash
   cd workspace
   terraform apply -var-file="devvars.tfvars"
   ```
   - Creates workspace with customer managed VPC, Unity Catalog integration, and service principal
   - Conditionally bypasses telemetry volume creation when `telemetry_location_name = null`
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

4. **Reapply Workspace SRA with Telemetry Integration (workspace)** 
   - Update `telemetry_location_name = "telemetry-data"` (name of external location created above) in devvars.tfvars
   - set `telemetry_bucket_name` with name of telemetry bucket and `telemetry_bucket_env_prefix` as the telemetry bucket prefix for the enviornment.
   ```bash
   cd workspace
   terraform apply -var-file="devvars.tfvars"
   ```
   - Detects telemetry external location and creates both external and managed telemetry volumes
   - Creates `telemetry` volume in raw schema for environment-specific data access
   - Creates `telemetry_metadata` volume for checkpoint data and processing metadata

5. **Multi-Workspace Deployment (workspace)**
   - For additional workspaces sharing the same metastore and telemetry data, use the workspace module with environment-specific variable files
   - Use [terraform worksapces](terraform workspace new dev) to manage multiple isolated environments—such as development, staging, and production—within a single configuration, each with its own state file and resources.
   - Ensure `telemetry_bucket_name`,  `telemetry_bucket_env_prefix`, and `telemetry_location_name` is configured if telemetry access is needed
    ```bash
   cd workspace
   terraform workspace new dev
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

### 3. Workspace (`workspace/`)

Deploys a Databricks workspace using a modular architecture based on the [Security Reference Architecture (SRA)](https://github.com/databricks/terraform-databricks-sra/tree/main/aws). The deployment creates a complete Databricks workspace with customer managed VPC, Unity Catalog catalog for the workspace,a service principal, and a volume to access telemetry data.

The workspace_SRA module orchestrates both account-level and workspace-level resources through organized sub-modules.

#### Databricks Account Modules (`modules/databricks_account/`)

##### `unity_catalog_metastore_assignment/`
- **Purpose**: Assigns Unity Catalog metastore to the workspace
- **Contents**: Links metastore to workspace for Unity Catalog functionality

##### `user_assignment/`
- **Purpose**: Assigns admin user permissions to the workspace
- **Contents**: Grants workspace ADMIN permissions to specified user account

##### `workspace/`
- **Purpose**: Core workspace infrastructure deployment
- **Contents**:
  - **Cross-Account IAM Role**: Secure credential configuration with time delays
  - **Storage Configuration**: Root bucket setup for DBFS storage
  - **Network Configuration**: VPC, subnet, and security group integration
  - **Private Access Settings**: Account-level private access configuration
  - **Workspace Creation**: Complete Databricks workspace with enterprise pricing tier and secure cluster connectivity

#### Databricks Workspace Modules (`modules/databricks_workspace/`)

##### `restrictive_root_bucket/`
- **Purpose**: Applies security-hardened bucket policies to root storage
- **Contents**:
  - **Restrictive Access Controls**: Limits Databricks access to specific paths and operations
  - **SSL Enforcement**: Denies non-SSL requests to enhance security

##### `system_schema/`
- **Purpose**: Enables Databricks system tables for observability and governance
- **Contents**: Creates system schemas for access, compute, lakeflow, marketplace, storage, serving, and query monitoring

##### `unity_catalog_catalog_creation/`
- **Purpose**: Creates Unity Catalog structure with security controls
- **Contents**:
  - **KMS Encryption**: Dedicated encryption key for catalog storage
  - **S3 Bucket**: Secure data lake bucket with encryption and versioning
  - **IAM Role**: Unity Catalog access role with least-privilege permissions
  - **Storage Credential**: Databricks credential for S3 access
  - **External Location**: Unity Catalog external location for data access
  - **Catalog and Schema Structure**: Organized data layer schemas

#### Core Configuration Files

#### `main.tf`
- **Purpose**: Orchestrates all modules and defines resource dependencies
- **Contents**: Module calls for workspace creation, metastore assignment, user permissions, catalog setup, system tables, and restrictive bucket policies

#### `network.tf`
- **Purpose**: Creates customer managed VPC infrastructure
- **Contents**: VPC, subnets, internet gateway, NAT gateway, and routing configuration

#### `vpc_endpoints.tf`
- **Purpose**: Establishes secure AWS service connectivity
- **Contents**: VPC endpoints for S3, Kinesis, and STS services

#### `credential.tf`
- **Purpose**: Creates cross-account IAM role for Databricks
- **Contents**: IAM role, policies, and trust relationships for secure AWS resource access

#### `root_s3_bucket.tf`
- **Purpose**: Creates root storage bucket for workspace
- **Contents**: S3 bucket with encryption, versioning, and security configurations

#### `service_principal.tf`
- **Purpose**: Creates workspace service principal for automated operations
- **Contents**: Job executor service principal with workspace ADMIN permissions for automation tasks

#### `telemetry_volume.tf`
- **Purpose**: Creates Unity Catalog volumes for telemetry data access
- **Contents**: 
  - **External Telemetry Volume**: Maps to environment-specific telemetry data in S3
  - **Managed Metadata Volume**: Stores checkpoint data and processing metadata
  - **Conditional Creation**: Only creates volumes if telemetry external location exists

#### Variable Files
Configure your workspace deployment with environment-specific values.

##### `devvars.tfvars`
- **Purpose**: Development environment variable values

