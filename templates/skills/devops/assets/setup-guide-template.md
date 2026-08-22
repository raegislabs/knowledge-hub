# Setup Guide Template

## Overview

This template provides a comprehensive setup guide structure for documenting installation, configuration, and initial usage of applications or tools. Includes troubleshooting, verification, and support information.

## Template

```markdown
# {Feature/Application Name} Setup Guide

## Overview

{Brief description of what this sets up and why it's useful. 2-3 sentences maximum.}

**Key Features:**
- {Feature 1}
- {Feature 2}
- {Feature 3}

**Use Cases:**
- {Use case 1}
- {Use case 2}

## Prerequisites

### Required
- **{Tool 1}** (version X.X+) - {Brief reason why needed}
- **{Tool 2}** (version Y.Y+) - {Brief reason why needed}
- **{Tool 3}** - {Brief reason why needed}

### Optional
- **{Optional Tool 1}** - For {specific feature}
- **{Optional Tool 2}** - For {specific feature}

### System Requirements
- **OS**: {Supported operating systems}
- **RAM**: {Minimum RAM}
- **Disk**: {Minimum disk space}
- **Network**: {Network requirements if any}

### Permissions
- {Required access level (sudo, admin, etc.)}
- {API keys or credentials needed}
- {File system permissions}

## Quick Start

For experienced users who want to get up and running quickly:

```bash
# Clone or download
git clone {repo-url}
cd {project-dir}

# Install dependencies
{package-manager} install

# Configure
cp .env.example .env
# Edit .env with your settings

# Initialize
{init-command}

# Start
{start-command}

# Verify
{verification-command}
```

**Expected output:**
```
{Sample successful output}
```

## Detailed Installation

### Step 1: Download/Clone

**Option A: Git Clone (Recommended)**
```bash
git clone {repo-url}
cd {project-dir}
```

**Option B: Download Archive**
1. Visit {download-url}
2. Download the latest release
3. Extract to desired location
4. Navigate to directory

**Option C: Package Manager**
```bash
{package-manager} install {package-name}
```

### Step 2: Install Dependencies

**For Python Projects:**
```bash
# Using pip
pip install -r requirements.txt

# Using pipenv
pipenv install

# Using poetry
poetry install
```

**For Node.js Projects:**
```bash
# Using npm
npm install

# Using yarn
yarn install

# Using pnpm
pnpm install
```

**For System Dependencies:**
```bash
# Ubuntu/Debian
sudo apt-get install {dependencies}

# macOS
brew install {dependencies}

# Windows (using Chocolatey)
choco install {dependencies}
```

### Step 3: Configuration

#### Environment Variables

Create `.env` file in project root:

```bash
# Copy template
cp .env.example .env
```

Edit `.env` with required values:

```bash
# Required Configuration
APP_NAME={your-app-name}
ENVIRONMENT={development|staging|production}
DEBUG={true|false}

# Database Configuration
DATABASE_URL={database-connection-string}
DATABASE_NAME={database-name}

# API Keys (if applicable)
API_KEY={your-api-key}
SECRET_KEY={your-secret-key}

# Optional Configuration
LOG_LEVEL={debug|info|warning|error}  # default: info
PORT={port-number}                     # default: 8000
HOST={host-address}                    # default: localhost
```

**Where to get API keys:**
- {Service 1}: Visit {url} to generate API key
- {Service 2}: Run `{command}` to create credentials

#### Configuration Files

**config.yml (or equivalent):**

```yaml
# {config-file-name}
app:
  name: {app-name}
  version: {version}
  environment: {environment}

database:
  host: {db-host}
  port: {db-port}
  name: {db-name}

features:
  feature1: {enabled|disabled}
  feature2: {enabled|disabled}
```

**Important configuration notes:**
- {Note about sensitive configuration}
- {Note about production vs development config}
- {Note about performance tuning}

### Step 4: Database Setup (if applicable)

**Create Database:**
```bash
# PostgreSQL
createdb {database-name}

# MySQL
mysql -u root -p -e "CREATE DATABASE {database-name};"

# SQLite (auto-created)
# No action needed
```

**Run Migrations:**
```bash
{migration-command}

# Example outputs:
# Django: python manage.py migrate
# Rails: rails db:migrate
# Alembic: alembic upgrade head
```

**Seed Initial Data (optional):**
```bash
{seed-command}

# Example:
# python manage.py loaddata initial_data.json
```

### Step 5: Initialize Application

```bash
{initialization-command}

# This may perform:
# - Creating required directories
# - Generating initial configuration
# - Setting up indexes
# - Running health checks
```

### Step 6: Start Application

**Development Mode:**
```bash
{dev-start-command}

# Example outputs:
# Flask: flask run
# Node: npm run dev
# Django: python manage.py runserver
```

**Production Mode:**
```bash
{prod-start-command}

# Example:
# gunicorn app:app
# pm2 start app.js
# systemctl start myapp
```

**With Docker:**
```bash
docker-compose up -d

# Or
docker run -d -p {port}:{port} {image-name}
```

**As a Service (Linux):**
```bash
sudo systemctl enable {service-name}
sudo systemctl start {service-name}
sudo systemctl status {service-name}
```

## Verification

### Health Check

```bash
# HTTP endpoint
curl http://localhost:{port}/health

# Expected response:
{
  "status": "healthy",
  "version": "{version}",
  "timestamp": "{timestamp}"
}
```

### Run Tests

```bash
# Unit tests
{test-command}

# Integration tests
{integration-test-command}

# E2E tests
{e2e-test-command}
```

### Check Logs

```bash
# Application logs
tail -f logs/application.log

# System logs (Linux)
journalctl -u {service-name} -f

# Docker logs
docker-compose logs -f
```

## Usage

### Basic Usage

```bash
# Example 1: {Common operation}
{command} {arguments}

# Example 2: {Another common operation}
{command} {arguments}
```

### CLI Commands

**List all available commands:**
```bash
{app-name} --help
```

**Common commands:**
```bash
# {Command description}
{app-name} {command} {args}

# {Command description}
{app-name} {command} --option value

# {Command description}
{app-name} {command} --flag
```

### API Usage (if applicable)

**Authentication:**
```bash
curl -H "Authorization: Bearer {token}" \
     http://localhost:{port}/api/endpoint
```

**Common endpoints:**
```bash
# GET request
curl http://localhost:{port}/api/resource

# POST request
curl -X POST http://localhost:{port}/api/resource \
     -H "Content-Type: application/json" \
     -d '{"key": "value"}'

# PUT request
curl -X PUT http://localhost:{port}/api/resource/{id} \
     -d '{"key": "updated_value"}'

# DELETE request
curl -X DELETE http://localhost:{port}/api/resource/{id}
```

### Web Interface (if applicable)

1. Open browser to `http://localhost:{port}`
2. {Navigation instructions}
3. {Key features to try}

## Troubleshooting

### Common Issues

#### Issue 1: {Installation fails with dependency error}

**Symptoms:**
```
{Error message shown to user}
```

**Cause:**
{What causes this error}

**Solution:**
```bash
{Commands to fix the issue}
```

#### Issue 2: {Application won't start}

**Symptoms:**
```
{Error message or behavior}
```

**Cause:**
{What causes this error}

**Solution:**
1. {Step 1 to diagnose}
2. {Step 2 to fix}
3. {Step 3 to verify}

#### Issue 3: {Database connection fails}

**Symptoms:**
```
{Error message}
```

**Cause:**
{Typical causes}

**Solution:**
```bash
# Verify database is running
{check-db-command}

# Test connection
{test-connection-command}

# Check credentials in .env
{verify-config-command}
```

#### Issue 4: {Port already in use}

**Symptoms:**
```
Error: Port {port} is already in use
```

**Solution:**
```bash
# Find process using port
lsof -i :{port}

# Kill process
kill -9 {PID}

# Or use different port
{app-name} --port {alternative-port}
```

#### Issue 5: {Permission denied}

**Symptoms:**
```
{Permission error message}
```

**Solution:**
```bash
# Fix file permissions
chmod +x {script-name}

# Or run with appropriate permissions
sudo {command}
```

### Debug Mode

Enable debug mode for detailed error messages:

```bash
# Environment variable
DEBUG=true {start-command}

# Command line flag
{app-name} --debug

# Configuration file
# Set debug: true in config file
```

### Getting Help

1. **Check logs first:**
   ```bash
   tail -f logs/application.log
   ```

2. **Run diagnostic command:**
   ```bash
   {app-name} diagnose
   ```

3. **Verify configuration:**
   ```bash
   {app-name} config validate
   ```

## Updating

### Update to Latest Version

**From Git:**
```bash
git pull origin main
{install-command}
{migration-command}
{restart-command}
```

**From Package Manager:**
```bash
{package-manager} update {package-name}
```

### Backup Before Update

```bash
# Backup database
{backup-db-command}

# Backup configuration
cp .env .env.backup
cp config.yml config.yml.backup

# Backup data directory
tar -czf data-backup-$(date +%Y%m%d).tar.gz data/
```

### Check Version

```bash
{app-name} --version
```

### Changelog

Review changes before updating:
- Visit {changelog-url}
- Check for breaking changes
- Review migration notes

## Uninstallation

### Stop Service

```bash
# Stop application
{stop-command}

# Disable systemd service (if applicable)
sudo systemctl disable {service-name}
```

### Remove Application

**Installed from Git:**
```bash
cd {project-dir}
rm -rf {project-dir}
```

**Installed from Package Manager:**
```bash
{package-manager} uninstall {package-name}
```

### Clean Up Data

```bash
# Remove database (⚠️ DATA LOSS)
{drop-database-command}

# Remove configuration
rm -f .env config.yml

# Remove logs
rm -rf logs/

# Remove cached data
rm -rf cache/ tmp/
```

### Remove Dependencies

```bash
# Python
pip uninstall -r requirements.txt -y

# Node
npm uninstall {package-name}
```

## Production Deployment

### Pre-deployment Checklist

- [ ] All tests passing
- [ ] Environment variables configured
- [ ] Database migrations tested
- [ ] SSL certificates installed
- [ ] Firewall rules configured
- [ ] Monitoring setup
- [ ] Backup strategy in place
- [ ] Rollback plan documented

### Security Hardening

```bash
# Disable debug mode
DEBUG=false

# Use strong secret keys
SECRET_KEY=$(openssl rand -hex 32)

# Configure HTTPS
# {Instructions for SSL setup}

# Set up firewall
{firewall-commands}
```

### Performance Tuning

```yaml
# config.yml
performance:
  workers: {number-of-workers}
  threads: {threads-per-worker}
  timeout: {timeout-seconds}
  keepalive: {keepalive-seconds}
```

### Monitoring

```bash
# Set up health checks
{monitoring-setup-command}

# Configure logging
{logging-config-command}

# Set up alerts
{alerting-config-command}
```

## Additional Resources

### Documentation
- **Official Documentation**: {docs-url}
- **API Reference**: {api-docs-url}
- **Tutorial**: {tutorial-url}

### Community
- **GitHub Issues**: {issues-url}
- **Discussion Forum**: {forum-url}
- **Chat/Discord**: {chat-url}

### Examples
- **Sample Projects**: {examples-url}
- **Code Snippets**: {snippets-url}
- **Video Tutorials**: {videos-url}

## Support

### Getting Help

1. **Check Documentation**: Review official docs at {docs-url}
2. **Search Issues**: Check {issues-url} for similar problems
3. **Ask Community**: Post in {forum-url}
4. **Create Issue**: Report bugs at {issues-url}

### Commercial Support

For enterprise support:
- Email: {support-email}
- Website: {support-website}
- SLA: {sla-details}

## License

{License information}

## Credits

{Credits and acknowledgments}

---

**Last Updated**: {Date}
**Version**: {Version}
**Maintainer**: {Maintainer contact}
```

## Customization Guide

### 1. Replace Placeholders

Search and replace these throughout:
- `{Feature/Application Name}` - Your app/tool name
- `{repo-url}` - Git repository URL
- `{project-dir}` - Installation directory
- `{port}` - Default port number
- `{package-manager}` - npm, pip, apt, etc.
- All `{command}` placeholders with actual commands

### 2. Tailor Sections

**Remove sections that don't apply:**
- Database Setup (for static tools)
- API Usage (for CLI-only tools)
- Web Interface (for APIs/CLIs)

**Add sections as needed:**
- Docker deployment
- Kubernetes configuration
- Cloud-specific setup (AWS, GCP, Azure)
- Integration guides

### 3. Customize Troubleshooting

Add 5-10 most common issues your users face:
- Installation problems
- Configuration errors
- Runtime issues
- Performance problems

### 4. Update Prerequisites

List actual requirements:
- Exact version numbers
- Why each prerequisite is needed
- Where to get them

## Features

### Comprehensive Coverage
- Quick start for experienced users
- Detailed walkthrough for beginners
- Production deployment guidance
- Troubleshooting section

### User-Friendly
- Clear structure and navigation
- Code examples for every step
- Expected outputs shown
- Multiple installation methods

### Production-Ready
- Security hardening section
- Performance tuning guidance
- Monitoring and logging
- Backup and rollback procedures

## Best Practices

1. **Test Every Command**: Verify all commands work as documented
2. **Show Expected Output**: Include sample output for verification
3. **Link to Resources**: Provide URLs for additional information
4. **Keep It Updated**: Update version numbers and commands
5. **Include Examples**: Real-world examples for every feature
6. **Address Common Issues**: Document frequent troubleshooting scenarios
7. **Production Focus**: Include deployment and security best practices

## Related Templates

- `deployment-script-template.md` - Automated deployment scripts
- `ci-cd-pipeline-template.md` - Continuous integration/deployment
- `docker-compose-template.md` - Container orchestration
- `monitoring-setup-template.md` - Observability configuration
