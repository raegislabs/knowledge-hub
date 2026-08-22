# Infrastructure as Code Best Practices

## Overview

Best practices for managing infrastructure with code using Terraform, ensuring consistency, reusability, and maintainability.

## Core Principles

### 1. Everything as Code
- Infrastructure definitions in version control
- No manual changes in cloud console
- Peer review for infrastructure changes
- Audit trail through Git history

### 2. DRY (Don't Repeat Yourself)
- Use modules for reusable components
- Variables for configuration
- Data sources for dynamic values
- Locals for computed values

### 3. Immutable Infrastructure
- Replace rather than modify
- Recreate instances instead of patching
- Blue-green deployments
- Version everything

## Module Structure

### Standard Layout
```
terraform-modules/
├── vpc/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── README.md
├── compute/
│   └── ...
└── database/
    └── ...
```

### Module Best Practices

**1. Single Responsibility**
```hcl
# ❌ Bad: Too many resources in one module
module "everything" {
  # VPC, compute, database, monitoring...
}

# ✅ Good: Focused modules
module "vpc" { }
module "compute" { }
module "database" { }
```

**2. Versioning**
```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"  # Pin to specific version
}
```

**3. Documentation**
```hcl
variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.medium"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Only t3 instance types are allowed."
  }
}
```

## State Management

### Remote State
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### State Locking
```hcl
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### Workspaces
```bash
# Create workspace
terraform workspace new staging

# List workspaces
terraform workspace list

# Switch workspace
terraform workspace select prod

# Current workspace
terraform workspace show
```

## Variable Management

### Variable Hierarchy
```
1. Environment variables (TF_VAR_*)
2. terraform.tfvars
3. terraform.tfvars.json
4. *.auto.tfvars
5. -var or -var-file flags
6. Default values
```

### Environment-Specific Variables
```hcl
# variables.tf
variable "environment" {
  type = string
}

variable "instance_count" {
  type = map(number)
  default = {
    dev     = 1
    staging = 2
    prod    = 5
  }
}

# Usage
resource "aws_instance" "app" {
  count = var.instance_count[var.environment]
}
```

### Sensitive Variables
```hcl
variable "database_password" {
  type      = string
  sensitive = true
}

output "db_password" {
  value     = var.database_password
  sensitive = true
}
```

## Naming Conventions

### Resources
```hcl
# Pattern: <resource-type>_<name>
resource "aws_security_group" "app_lb" { }
resource "aws_instance" "web_server" { }
```

### Variables
```hcl
# Use descriptive names
variable "vpc_cidr_block" { }        # ✅ Clear
variable "cidr" { }                  # ❌ Vague
```

### Tags
```hcl
locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.team_email
  }
}

resource "aws_instance" "app" {
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-app"
      Role = "application-server"
    }
  )
}
```

## Resource Management

### Lifecycle Rules
```hcl
resource "aws_instance" "app" {
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags["LastUpdated"]]
  }
}
```

### Dependencies
```hcl
# Explicit dependency
resource "aws_instance" "app" {
  depends_on = [aws_db_instance.main]
}

# Implicit dependency (preferred)
resource "aws_instance" "app" {
  subnet_id = aws_subnet.main.id
}
```

### Count vs For_Each
```hcl
# ❌ Count: Changes index if item removed
resource "aws_instance" "app" {
  count = length(var.availability_zones)
}

# ✅ For_each: Stable keys
resource "aws_instance" "app" {
  for_each = toset(var.availability_zones)
  availability_zone = each.key
}
```

## Data Sources

### Dynamic Configuration
```hcl
# Latest AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

# Current region
data "aws_region" "current" {}

# Availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
```

## Security Best Practices

### 1. Never Commit Secrets
```hcl
# ❌ Never do this
variable "api_key" {
  default = "secret123"
}

# ✅ Use variables without defaults
variable "api_key" {
  type      = string
  sensitive = true
}

# ✅ Or use secret management
data "aws_secretsmanager_secret_version" "api_key" {
  secret_id = "prod/api_key"
}
```

### 2. Least Privilege
```hcl
resource "aws_iam_policy" "app" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.app.arn}/*"
      }
    ]
  })
}
```

### 3. Encryption
```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

## Testing

### Validation
```bash
# Format check
terraform fmt -check -recursive

# Validate configuration
terraform validate

# Plan with detailed output
terraform plan -out=tfplan
```

### Automated Testing
```go
// Using Terratest
func TestTerraformVPC(t *testing.T) {
    opts := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/vpc",
    })

    defer terraform.Destroy(t, opts)
    terraform.InitAndApply(t, opts)

    vpcID := terraform.Output(t, opts, "vpc_id")
    assert.NotEmpty(t, vpcID)
}
```

## Workflow

### Standard Workflow
```bash
# 1. Initialize
terraform init

# 2. Plan
terraform plan -out=tfplan

# 3. Review plan
terraform show tfplan

# 4. Apply
terraform apply tfplan

# 5. Verify
terraform show
```

### CI/CD Integration
```yaml
# GitHub Actions
- name: Terraform Plan
  run: |
    terraform init
    terraform plan -out=tfplan

- name: Terraform Apply
  if: github.ref == 'refs/heads/main'
  run: terraform apply -auto-approve tfplan
```

## Common Patterns

### Environment Separation
```
terraform/
├── modules/
│   └── vpc/
├── environments/
    ├── dev/
    │   ├── main.tf
    │   └── terraform.tfvars
    ├── staging/
    └── prod/
```

### Shared State Access
```hcl
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
}
```

## Troubleshooting

### State Drift
```bash
# Detect drift
terraform plan -refresh=true

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_instance.app i-1234567890
```

### Stuck Resources
```bash
# Remove from state
terraform state rm aws_instance.stuck

# Move resource
terraform state mv aws_instance.old aws_instance.new
```

## Best Practices Checklist

- [ ] Remote state with locking
- [ ] Modules for reusable components
- [ ] Variables with validation
- [ ] Consistent naming conventions
- [ ] Common tags on all resources
- [ ] No secrets in code
- [ ] Version pinning for providers and modules
- [ ] .gitignore for sensitive files
- [ ] Documentation in README
- [ ] Automated testing

## Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Google Cloud Terraform Best Practices](https://cloud.google.com/docs/terraform/best-practices-for-terraform)
- [AWS Terraform Best Practices](https://aws-ia.github.io/standards-terraform/)
