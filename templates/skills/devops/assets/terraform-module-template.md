# Terraform Module Template

## Overview

Production-ready Terraform module structure with variables, outputs, data sources, and best practices for infrastructure as code.

## Module Structure

```
terraform-module/
├── main.tf           # Main resource definitions
├── variables.tf      # Input variable declarations
├── outputs.tf        # Output value declarations
├── versions.tf       # Provider version constraints
├── README.md         # Module documentation
├── examples/         # Usage examples
│   ├── basic/
│   │   ├── main.tf
│   │   └── variables.tf
│   └── complete/
│       ├── main.tf
│       └── variables.tf
└── modules/          # Submodules (optional)
    └── submodule/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## main.tf

```hcl
# =============================================================================
# Terraform Configuration
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration (example)
  backend "s3" {
    bucket         = "terraform-state-bucket"
    key            = "myapp/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

# =============================================================================
# Data Sources
# =============================================================================

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# Local Values
# =============================================================================

locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Terraform   = "true"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  )

  # Computed values
  name_prefix = "${var.project_name}-${var.environment}"

  # Availability zones
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# =============================================================================
# VPC Resources
# =============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-${local.azs[count.index]}"
      Type = "public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(local.azs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.azs))
  availability_zone = local.azs[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-${local.azs[count.index]}"
      Type = "private"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.create_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

# NAT Gateway (with EIP)
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? length(local.azs) : 0
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-eip-${local.azs[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = var.create_nat_gateway ? length(local.azs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-nat-${local.azs[count.index]}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# Route Tables
# =============================================================================

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-public-rt"
    }
  )
}

# Public Route to Internet
resource "aws_route" "public_internet" {
  count = var.create_internet_gateway ? 1 : 0

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "private" {
  count = length(local.azs)

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-private-rt-${local.azs[count.index]}"
    }
  )
}

# Private Route to NAT Gateway
resource "aws_route" "private_nat" {
  count = var.create_nat_gateway ? length(local.azs) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# =============================================================================
# Security Groups
# =============================================================================

resource "aws_security_group" "app" {
  name_prefix = "${local.name_prefix}-app-"
  description = "Security group for application"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-app-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  count = var.enable_http ? 1 : 0

  security_group_id = aws_security_group.app.id
  description       = "Allow HTTP inbound"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "app_https" {
  count = var.enable_https ? 1 : 0

  security_group_id = aws_security_group.app.id
  description       = "Allow HTTPS inbound"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_all" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound"

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# =============================================================================
# Conditional Resources Example
# =============================================================================

resource "aws_s3_bucket" "logs" {
  count = var.enable_logging ? 1 : 0

  bucket = "${local.name_prefix}-logs"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "logs" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = var.enable_logging ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

## variables.tf

```hcl
# =============================================================================
# Required Variables
# =============================================================================

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string

  validation {
    condition     = length(var.project_name) > 0 && length(var.project_name) <= 32
    error_message = "Project name must be between 1 and 32 characters."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# =============================================================================
# VPC Configuration
# =============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 6
    error_message = "AZ count must be between 2 and 6."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

# =============================================================================
# Gateway Configuration
# =============================================================================

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

# =============================================================================
# Security Configuration
# =============================================================================

variable "enable_http" {
  description = "Enable HTTP access"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS access"
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access resources"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# =============================================================================
# Feature Flags
# =============================================================================

variable "enable_logging" {
  description = "Enable centralized logging"
  type        = bool
  default     = false
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

# =============================================================================
# Tags
# =============================================================================

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

## outputs.tf

```hcl
# =============================================================================
# VPC Outputs
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

# =============================================================================
# Subnet Outputs
# =============================================================================

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

# =============================================================================
# Gateway Outputs
# =============================================================================

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = try(aws_internet_gateway.main[0].id, null)
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_eips" {
  description = "List of NAT Gateway Elastic IPs"
  value       = aws_eip.nat[*].public_ip
}

# =============================================================================
# Security Group Outputs
# =============================================================================

output "app_security_group_id" {
  description = "ID of the application security group"
  value       = aws_security_group.app.id
}

# =============================================================================
# Convenience Outputs
# =============================================================================

output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}

output "name_prefix" {
  description = "Name prefix used for resources"
  value       = local.name_prefix
}
```

## versions.tf

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
```

## Usage Example

```hcl
# examples/basic/main.tf

module "vpc" {
  source = "../../"

  project_name = "myapp"
  environment  = "dev"

  vpc_cidr = "10.0.0.0/16"
  az_count = 2

  create_internet_gateway = true
  create_nat_gateway      = true

  enable_http  = true
  enable_https = true

  tags = {
    Owner = "DevOps Team"
    Cost  = "Development"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}
```

## Best Practices

### 1. Use Variables with Validation
```hcl
variable "environment" {
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Invalid environment."
  }
}
```

### 2. Use Local Values for DRY
```hcl
locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
```

### 3. Use Data Sources
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
}
```

### 4. Lifecycle Rules
```hcl
lifecycle {
  create_before_destroy = true
  prevent_destroy       = true
  ignore_changes        = [tags]
}
```

### 5. Depends On (when needed)
```hcl
depends_on = [aws_internet_gateway.main]
```

## Commands

```bash
# Initialize
terraform init

# Format code
terraform fmt -recursive

# Validate
terraform validate

# Plan
terraform plan

# Apply
terraform apply

# Destroy
terraform destroy

# Show state
terraform show

# List resources
terraform state list

# Import existing resource
terraform import aws_vpc.main vpc-12345
```

## Related Templates

- `github-actions-pipeline-template.md` - CI/CD for Terraform
- `kubernetes-deployment-template.md` - Deploy to Kubernetes
