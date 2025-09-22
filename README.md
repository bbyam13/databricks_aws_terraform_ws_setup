# Databricks AWS Terraform Workspace Setup

This Terraform project automates the deployment of a Databricks environment on AWS including account-level configuration, telemetry data access from an existing S3 bucket, and workspace deployment with Unity Catalog integration.

## Project Structure

The project is organized as a unified Terraform deployment that creates account-level resources (Unity Catalog metastore and account groups) and workspace deployment in a single coordinated process. The deployment creates foundational resources that are shared across workspaces - the Unity Catalog metastore and account groups, and workspaces with customer managed VPC along with associated UC catalogs with multiple schemas and permissions for the account groups. Each workspace creates its own telemetry data access infrastructure when enabled. It is designed to handle deploying several workspaces within the same account using the same Unity Catalog metastore.

**PLEASE NOTE**: Each workspace creates its own independent telemetry access infrastructure (external locations and volume) for the environment-specific folder within the shared telemetry S3 bucket. This allows workspaces to be safely deleted or created without affecting telemetry data access for other workspaces.

## Setup

### Prerequisites
- **Terraform** installed
- **AWS CLI** Installed
- **Databricks CLI**  Installed
- **Databricks Service Principal** created in Databricks account for automation with Account Admin access

### 2. Authentication with AWS and Databricks

#### AWS Authentication
Configure AWS credentials using one of these methods:

```bash
# Option 1: AWS CLI configure
aws configure
# Enter your AWS Access Key ID, Secret Access Key, region, and output format

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-2"

# Option 3: AWS Profile (if using multiple accounts)
export AWS_PROFILE="your-profile-name"

# Verify AWS authentication
aws sts get-caller-identity
```

#### Databricks Authentication
Set up Databricks authentication using environment variables:

```bash
export DATABRICKS_CLIENT_ID="your-service-principal-client-id"
export DATABRICKS_CLIENT_SECRET="your-service-principal-client-secret"
```



### 3. Configure Variables
rename `terraform.tfvars.example` -> `terraform.tfvars`
Edit `terraform.tfvars` with your specific values:

```hcl
# =============================================================================
# AWS Configuration
# =============================================================================
aws_account_id = "123456789012"           # Your AWS account ID
region = "us-east-2"                      # Your preferred AWS region

# =============================================================================
# Databricks Configuration  
# =============================================================================
admin_user = "your-email@company.com"     # Your admin email
metastore_name = "your-metastore-name"    # Name Unity Catalog metastore name (will be created)
executor_application_id = "abc123..."     # Service principal app ID
databricks_account_id = "xyz789..."       # Your Databricks account ID

# =============================================================================
# Telemetry Configuration (Optional)
# =============================================================================
telemetry_bucket_name = "your-telemetry-bucket"    # Set to null to disable
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy the infrastructure
terraform apply
```

### 5.  Add and Destroy Workspaces

#### Add a new workspace
  1. Add a new workspace provider in `providers.tf`

  ```hcl
    provider "databricks" {
      alias      = "STAGE_workspace"
      host       = module.STAGE_workspace.databricks_host #this must match the module name
      account_id = var.databricks_account_id
    }
  ```

  2. Copy a sample workspace file - `workspace_dev.tf`
  3. Modify the file for specs of the new workspace

  ```hcl
    module "STAGE_workspace" { #update to unique name
        
        ......
          
          databricks.created_workspace = databricks.STAGE_workspace 
        
        .......

        #variables per workspace
        resource_prefix                 = "byam-STAGE" #name of the workspace
        deployment_name                 = "byam-STAGE" #url of workspace 
        telemetry_bucket_env_prefix     = "STAGE"  # bucket prefix
        
        #Whether the catalog is accessible from all workspaces or a specific set of workspaces
        catalog_isolation_mode          = "OPEN"
      
      .......

      #workspace specific outputs
      output "STAGE_workspace_url" { #update this to match the module name
        value       = module.STAGE_workspace.databricks_host #update this to match the module nam

      .......

      output "STAGE_workspace_service_principal_id" { #update this to match the module name
        value       = module.STAGE_workspace.service_principal_application_id #update this to match the module name
  ```
  
  4. Deploy 
  ```bash
# Initialize Terraform to add new module
terraform init

# Review the deployment plan
terraform plan

# Deploy the new workspace resources
terraform apply
```
#### Destroy a workspace

1. Destroy the specific workspace module
```bash

# Review the deployment plan
terraform plan -destroy -target=module.prod_workspace

# Deploy the new workspace resources
terraform apply -destroy -target=module.prod_workspace
```

**WARNING: The command `terraform destroy` WILL ATTEMPT TO DELETE ALL RESOURCES**





## Architecture

### 1. Account Level Configuration

The account-level configuration creates foundational resources that will be used across workspaces - the Unity Catalog metastore and account groups

#### `account_groups.tf`
- **Purpose**: Creates account-level user groups with automated member assignments
- **Contents**:
  - **Locals Configuration**: Defines all group configurations using a `locals` block for maintainability
  - **Dynamic Group Creation**: Uses `for_each` to create groups based on the local configuration
  - **Group Types Created**:
    - **Data Engineers Group**: Full workspace access with cluster creation privileges
    - **Data Analysts Group**: Workspace and SQL access for analysis tasks
    - **Data Scientists Group**: Workspace and SQL access for ML/analytics work
    - **Product Managers Group**: Workspace and SQL access for business insights
    - **Design Group**: Workspace and SQL access for design-related analytics
    - **Backend Group**: Workspace access for backend development teams
    - **Metastore Admin Group**: Ownership and control over metastore
  - **Admin User Assignment**: Automatically assigns the specified admin user to metastore admins group
  - **Service Principal Assignment**: Automatically assigns the executor service principal to metastore admins group

#### `account_metastore.tf`
- **Purpose**: Creates the Unity Catalog metastore
- **Contents**:
  - Unity Catalog metastore resource configuration
  - Ownership assignment to specified user



### 2. Workspace Deployment (`modules/workspace_setup/`)

Deploys a Databricks workspace using a modular architecture based on the [Security Reference Architecture (SRA) Template](https://github.com/databricks/terraform-databricks-sra/tree/main/aws). The deployment creates a complete Databricks workspace with customer managed VPC, Unity Catalog catalog for the workspace, a service principal, and volumes to access telemetry data (when enabled).

The workspace module orchestrates both account and workspace API resources through organized sub-modules.

#### Databricks Account API Modules (`databricks_account/`)

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

#### Databricks Workspace API Modules (`databricks_workspace/`)

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
  - **S3 Bucket**: Secure data lake bucket with encryption by SSE-S3 (`main.tf`)
  - **IAM Role**: Unity Catalog access role with least-privilege permissions (`main.tf`)
  - **Storage Credential**: Databricks credential for S3 access (`main.tf`)
  - **External Location**: Unity Catalog external location for data access (`main.tf`)
  - **Catalog and Schema Structure**: Creates bronze, silver, gold, playground, reference, finance, and raw schemas (`catalog_structure.tf`)

##### `telemetry_external_location/`
- **Purpose**: Creates read-only external location for telemetry data access per workspace. Access is specific to the telemetry bucket prefix/folder provided. The external location is set up to utilize managed file events for better scalability with autoloader
- **Contents** (`uc_external_location_read_only.tf`):
  - **Storage Credential**: Links to telemetry IAM role for S3 bucket access
  - **External Location**: Read-only Unity Catalog external location for environment-specific telemetry data with managed SQS file events
  - **Conditional Creation**: Only creates when telemetry bucket is configured

#### Core Configuration Files

##### `main.tf`
- **Purpose**: Orchestrates all modules and defines resource dependencies
- **Contents**: Module calls for workspace creation, metastore assignment, user permissions, catalog setup, system tables, restrictive bucket policies, and telemetry external location (when enabled)

##### `catalog_permissions.tf`
- **Purpose**: Manages Unity Catalog permissions for account groups
- **Contents**: 
  - **Catalog Access Grants**: Grants USE_CATALOG permissions to account groups
  - **Schema-Level Permissions**: Configures granular permissions for bronze, silver, gold, reference, and raw schemas
  - **Role-Based Access**: Different privilege levels for data engineers, analysts, scientists, product managers, design, and backend teams

##### `network.tf`
- **Purpose**: Creates customer managed VPC infrastructure
- **Contents**: VPC, subnets, internet gateway, NAT gateway, and routing configuration

##### `vpc_endpoints.tf`
- **Purpose**: Establishes secure AWS service connectivity
- **Contents**: VPC endpoints for S3, Kinesis, and STS services

##### `credential.tf`
- **Purpose**: Creates cross-account IAM role for Databricks
- **Contents**: IAM role, policies, and trust relationships for secure AWS resource access

##### `root_s3_bucket.tf`
- **Purpose**: Creates root storage bucket for workspace
- **Contents**: S3 bucket with encryption (SSE-S3)

##### `service_principal.tf`
- **Purpose**: Creates workspace service principal for automated operations
- **Contents**: Job executor service principal with workspace ADMIN permissions for automation tasks

##### `telemetry_volume.tf`
- **Purpose**: Creates Unity Catalog volumes for telemetry data access
- **Contents**: 
  - **External Telemetry Volume**: Maps to environment-specific telemetry data in S3 bucket
  - **Managed Telemetry Metadata Volume**: Stores checkpoint data and processing metadata
  - **Conditional Creation**: Only creates volumes when telemetry bucket is configured