# Deployment Script Template

## Overview

This template provides a production-ready bash deployment script with:
- Comprehensive error handling and logging
- Colored output for readability
- Prerequisites checking
- Idempotent operations
- Clear progress reporting

## Template

```bash
#!/bin/bash
# {Feature Name} Deployment Script
# Description: {Brief description of what this script deploys}
# Usage: ./{script-name}.sh [options]
# Author: DevOps Team
# Version: 1.0.0

set -e  # Exit on error
set -u  # Error on undefined variables

# Color output for readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#=============================================================================
# Configuration
#=============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="${PROJECT_ROOT}/logs/deployment-$(date +%Y%m%d-%H%M%S).log"

# Default configuration (can be overridden by environment variables)
ENVIRONMENT="${ENVIRONMENT:-development}"
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"

#=============================================================================
# Logging Functions
#=============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2 | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_debug() {
    if [ "$VERBOSE" = "true" ]; then
        echo -e "${BLUE}[DEBUG]${NC} $1" | tee -a "$LOG_FILE"
    fi
}

log_success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$LOG_FILE"
}

#=============================================================================
# Utility Functions
#=============================================================================

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if running with required privileges
check_privileges() {
    if [ "$EUID" -ne 0 ] && [ "$REQUIRE_SUDO" = "true" ]; then
        log_error "This script must be run with sudo privileges"
        exit 1
    fi
}

# Cleanup function for trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Deployment failed with exit code $exit_code"
        log_info "Check log file: $LOG_FILE"
    fi
    # Add cleanup tasks here
}

# Set trap for cleanup
trap cleanup EXIT

#=============================================================================
# Prerequisites Checking
#=============================================================================

check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check for required directories
    if [ ! -d "$PROJECT_ROOT" ]; then
        log_error "Project root not found: $PROJECT_ROOT"
        exit 1
    fi

    # Create logs directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"

    # Check for required commands
    local required_commands=("python3" "git")
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            log_error "$cmd is required but not installed"
            exit 1
        fi
        log_debug "$cmd is available"
    done

    # Check for required files
    local required_files=("requirements.txt" "README.md")
    for file in "${required_files[@]}"; do
        if [ ! -f "$PROJECT_ROOT/$file" ]; then
            log_warning "Required file not found: $file"
        fi
    done

    # Check environment-specific prerequisites
    case "$ENVIRONMENT" in
        production)
            log_info "Validating production environment..."
            # Add production-specific checks
            ;;
        staging)
            log_info "Validating staging environment..."
            # Add staging-specific checks
            ;;
        development)
            log_info "Validating development environment..."
            # Add development-specific checks
            ;;
        *)
            log_error "Unknown environment: $ENVIRONMENT"
            exit 1
            ;;
    esac

    log_success "Prerequisites check passed"
}

#=============================================================================
# Deployment Steps
#=============================================================================

step_backup() {
    log_info "Step 1: Creating backup..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would create backup"
        return 0
    fi

    # Create backup directory
    local backup_dir="$PROJECT_ROOT/backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"

    # Backup critical files
    # cp -r "$PROJECT_ROOT/config" "$backup_dir/"

    log_success "Backup created: $backup_dir"
}

step_dependencies() {
    log_info "Step 2: Installing dependencies..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would install dependencies"
        return 0
    fi

    cd "$PROJECT_ROOT"

    # Install Python dependencies
    if [ -f "requirements.txt" ]; then
        python3 -m pip install -r requirements.txt --upgrade
        log_success "Python dependencies installed"
    fi

    # Install Node dependencies (if applicable)
    if [ -f "package.json" ]; then
        npm install
        log_success "Node dependencies installed"
    fi
}

step_database_migration() {
    log_info "Step 3: Running database migrations..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would run database migrations"
        return 0
    fi

    # Add database migration commands
    # python3 manage.py migrate

    log_success "Database migrations completed"
}

step_build() {
    log_info "Step 4: Building application..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would build application"
        return 0
    fi

    # Add build commands
    # npm run build
    # python3 setup.py build

    log_success "Application built successfully"
}

step_deploy() {
    log_info "Step 5: Deploying application..."

    if [ "$DRY_RUN" = "true" ]; then
        log_info "[DRY RUN] Would deploy application"
        return 0
    fi

    # Add deployment commands
    # systemctl restart myapp
    # docker-compose up -d

    log_success "Application deployed successfully"
}

step_verify() {
    log_info "Step 6: Verifying deployment..."

    # Add verification commands
    # curl -f http://localhost:8000/health || exit 1

    log_success "Deployment verified successfully"
}

#=============================================================================
# Main Deployment Function
#=============================================================================

deploy() {
    log_info "Starting deployment to $ENVIRONMENT environment..."
    log_info "Dry run mode: $DRY_RUN"
    log_info "Verbose mode: $VERBOSE"
    echo

    # Execute deployment steps
    step_backup
    step_dependencies
    step_database_migration
    step_build
    step_deploy
    step_verify

    echo
    log_success "Deployment completed successfully!"
    log_info "Log file: $LOG_FILE"
}

#=============================================================================
# Rollback Function
#=============================================================================

rollback() {
    log_warning "Starting rollback process..."

    # Add rollback logic
    local latest_backup=$(ls -t "$PROJECT_ROOT/backups" | head -n1)
    if [ -n "$latest_backup" ]; then
        log_info "Rolling back to: $latest_backup"
        # Restore from backup
    else
        log_error "No backups found for rollback"
        exit 1
    fi

    log_success "Rollback completed"
}

#=============================================================================
# Help Function
#=============================================================================

show_help() {
    cat << EOF
Usage: ${0##*/} [OPTIONS]

Deploy the application to specified environment.

OPTIONS:
    -e, --environment ENV    Target environment (development|staging|production)
                             Default: development
    -d, --dry-run           Run in dry-run mode (no actual changes)
    -v, --verbose           Enable verbose output
    -r, --rollback          Rollback to previous deployment
    -h, --help              Display this help message

ENVIRONMENT VARIABLES:
    ENVIRONMENT             Same as --environment
    DRY_RUN                 Same as --dry-run (true|false)
    VERBOSE                 Same as --verbose (true|false)

EXAMPLES:
    # Deploy to development
    ${0##*/}

    # Deploy to production
    ${0##*/} --environment production

    # Dry run for staging
    ${0##*/} -e staging --dry-run

    # Rollback production deployment
    ${0##*/} -e production --rollback

EOF
}

#=============================================================================
# Argument Parsing
#=============================================================================

ROLLBACK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -r|--rollback)
            ROLLBACK=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

#=============================================================================
# Main Execution
#=============================================================================

main() {
    # Display banner
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Deployment Script${NC}"
    echo -e "${BLUE}================================${NC}"
    echo

    check_prerequisites

    if [ "$ROLLBACK" = "true" ]; then
        rollback
    else
        deploy
    fi
}

# Run main function
main "$@"
```

## Customization Guide

### 1. Basic Information
Replace these placeholders:
- `{Feature Name}` - Your application/feature name
- `{Brief description}` - What this script deploys
- `{script-name}` - The actual script filename

### 2. Configuration Section
Update these variables:
- `PROJECT_ROOT` - Your project's root directory
- `LOG_FILE` - Where to store deployment logs
- Add environment-specific configuration

### 3. Prerequisites
Modify `check_prerequisites()`:
- Add/remove required commands
- Add/remove required files
- Add environment-specific validation

### 4. Deployment Steps
Customize each step function:
- `step_backup()` - What to backup before deployment
- `step_dependencies()` - How to install dependencies
- `step_database_migration()` - Database migration commands
- `step_build()` - Build process
- `step_deploy()` - Actual deployment commands
- `step_verify()` - Health checks and verification

### 5. Rollback Logic
Implement `rollback()` function with:
- Backup restoration
- Service restart
- Database rollback if needed

## Features

### Error Handling
- `set -e` exits on any error
- `set -u` catches undefined variables
- Trap cleanup on exit
- Comprehensive error messages

### Logging
- Color-coded output (info, error, warning, debug, success)
- All output logged to file
- Timestamped log files
- Verbose mode for debugging

### Idempotency
- Safe to run multiple times
- Checks before destructive operations
- Dry-run mode for testing

### Flexibility
- Environment-aware (dev/staging/production)
- Command-line arguments and environment variables
- Rollback capability
- Help documentation

## Best Practices

1. **Test in Dry-Run First**: Always test with `--dry-run` before actual deployment
2. **Backup Everything**: Implement comprehensive backup before changes
3. **Verify After Deploy**: Always include verification step
4. **Log Everything**: Keep detailed logs for troubleshooting
5. **Handle Errors Gracefully**: Provide clear error messages and cleanup
6. **Make It Idempotent**: Safe to run multiple times without side effects
7. **Document Usage**: Include help text and examples

## Usage Examples

```bash
# Basic deployment to development
./deploy.sh

# Deploy to production
./deploy.sh --environment production

# Dry run to staging
./deploy.sh -e staging --dry-run

# Verbose deployment to production
./deploy.sh -e production --verbose

# Rollback production deployment
./deploy.sh -e production --rollback

# Using environment variables
ENVIRONMENT=production DRY_RUN=true VERBOSE=true ./deploy.sh
```

## Common Issues

### Issue: Permission Denied
**Solution**: Make script executable
```bash
chmod +x deploy.sh
```

### Issue: Command Not Found
**Solution**: Update `required_commands` array with actual dependencies

### Issue: Backup Directory Full
**Solution**: Implement backup rotation in `step_backup()`

## Related Templates

- `setup-guide-template.md` - For installation documentation
- `ci-cd-pipeline-template.md` - For automated deployments
- `docker-compose-template.md` - For containerized deployments
