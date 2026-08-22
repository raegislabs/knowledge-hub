# How to Set Up Deterministic Port Assignment

**Quick Setup Guide**: Follow these steps to configure conflict-free local development ports

---

## Prerequisites

- macOS Sonoma or Ubuntu 22.04+
- Homebrew package manager installed
- Terminal access (zsh or bash)
- 10-15 minutes for first-time setup

---

## Part 1: System-Wide Setup (One-Time Per Machine)

### Step 1: Install direnv

```bash
# Install direnv
brew install direnv

# Add to your shell (choose one)
# For zsh:
echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
source ~/.zshrc

# For bash:
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc

# Verify installation
direnv version
```

**Expected output**: `direnv 2.37.1` (or newer)

---

### Step 2: Install Docker

Choose either Docker Desktop OR Colima (not both):

**Option A: Docker Desktop** (Recommended for beginners)
```bash
brew install --cask docker
# Start Docker Desktop from Applications folder
# Wait for Docker to be running (whale icon in menu bar)
```

**Option B: Colima** (Lightweight alternative)
```bash
# Install Docker CLI and Colima
brew install docker colima

# Start Colima
colima start

# Configure Docker to use Colima
docker context use colima

# Verify Docker is working
docker ps
```

**Install Docker Compose plugin**:
```bash
brew install docker-compose

# Configure Docker to find the plugin
mkdir -p ~/.docker
echo '{"cliPluginsExtraDirs": ["/opt/homebrew/lib/docker/cli-plugins"]}' > ~/.docker/config.json

# Verify Docker Compose works
docker compose version
```

**Expected output**: `Docker Compose version v2.x.x`

---

### Step 3: Copy Helper Scripts

```bash
# Create ~/bin directory if it doesn't exist
mkdir -p ~/bin

# Add ~/bin to your PATH (if not already added)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
export PATH="$HOME/bin:$PATH"

# Navigate to the agent-orchestration-framework repository
cd /path/to/agent-orchestration-framework

# Copy helper scripts
cp scripts/dev-proxy/portbase.py ~/bin/portbase
cp scripts/dev-proxy/add-proj.sh ~/bin/add-proj

# Make them executable
chmod +x ~/bin/portbase ~/bin/add-proj

# Test portbase
portbase
```

**Expected output**: A number between 4000 and 4999

---

### Step 4: Launch Traefik Proxy (Optional but Recommended)

**What is Traefik?**
- Provides friendly URLs like `myproject.localtest.me` instead of `localhost:4387`
- Runs in the background continuously (like Docker Desktop)
- **Optional**: You can skip this and use direct localhost URLs

**When do you need it?**
- ✅ Want friendly URLs for easier development
- ✅ Working on multiple services that call each other
- ✅ Testing CORS or cookie behavior
- ❌ Okay with `localhost:PORT` URLs → Skip this step

**Setup**:
```bash
# Create proxy directory
mkdir -p ~/dev-proxy

# Navigate to the agent-orchestration-framework repository
cd /path/to/agent-orchestration-framework

# Copy Traefik configuration files
cp scripts/dev-proxy/docker-compose.yml ~/dev-proxy/
cp scripts/dev-proxy/traefik_dynamic.yml ~/dev-proxy/

# Start Traefik (runs continuously in background)
cd ~/dev-proxy
docker compose up -d

# Verify Traefik is running
docker compose ps
```

**Expected output**: Container "traefik" with status "Up"

**Verify Traefik dashboard**:
```bash
# Should return HTML content
curl -L http://localhost:8080

# Should return 404 (no routes configured yet - this is normal)
curl http://localhost:9999
```

**Open dashboard in browser**: http://localhost:8080

**Managing Traefik**:
```bash
# Check status
docker compose -f ~/dev-proxy/docker-compose.yml ps

# Stop (if needed)
cd ~/dev-proxy && docker compose down

# Start again
cd ~/dev-proxy && docker compose up -d

# Restart (after config changes)
cd ~/dev-proxy && docker compose restart traefik
```

**Note**: The `/init-port-assign` command will offer to start Traefik automatically if it's not running.

---

### Step 5: Verify System Setup

```bash
# Test portbase in different directories
cd /tmp && portbase        # Should show one port number
cd ~ && portbase          # Should show a different port number

# Check Traefik is running
docker compose -f ~/dev-proxy/docker-compose.yml ps

# Verify direnv is active
direnv status
```

✅ **System setup complete!** You only need to do this once per machine.

---

## Part 2: Per-Project Setup

### Method 1: Using `/init-port-assign` Command (Recommended)

```bash
# Navigate to your project
cd /path/to/your/project

# Run the automated setup command
/init-port-assign

# Follow the interactive prompts:
# 1. Confirm project type detection
# 2. Choose services to configure (frontend, API, database, etc.)
# 3. Review generated configuration
# 4. Confirm to proceed

# Allow direnv to load the configuration
direnv allow
```

**What this creates**:
- `.envrc` - Environment variables with your ports
- `start.sh` - Startup script for your project
- `proxy_commands.sh` - Commands to register with Traefik
- `PORT_CONFIG.md` - Documentation for your team

**Next steps**:
```bash
# Register with Traefik proxy (if not done automatically)
bash proxy_commands.sh

# Start your development server
./start.sh
# OR use your existing command (npm run dev, etc.)

# Test direct access
curl http://localhost:$WEB_PORT

# Test proxy access
curl http://yourproject.localtest.me
```

---

### Method 2: Manual Setup

#### 1. Create `.envrc` file

In your project root:
```bash
cat > .envrc << 'EOF'
# Deterministic port assignment
export BASE_PORT=$(portbase)
export WEB_PORT=$BASE_PORT
export API_PORT=$((BASE_PORT+1))
export DB_PORT=$((BASE_PORT+2))
export DOCS_PORT=$((BASE_PORT+3))
export WS_PORT=$((BASE_PORT+4))

# Custom domain
export PROJECT_DOMAIN="myproject.localtest.me"
EOF

# Activate direnv
direnv allow

# Verify ports are set
echo "Web: $WEB_PORT"
echo "API: $API_PORT"
```

---

#### 2. Update Your Application Code

Add port priority checking to your application:

**For Node.js/Express**:

Edit your main server file (e.g., `server.js`, `app.js`, `index.js`):
```javascript
// Add this at the top of your server file
const PORT = process.env.PORT || process.env.WEB_PORT || 3000;

// Update your app.listen call
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
```

**For Next.js**:

Edit `package.json`:
```json
{
  "scripts": {
    "dev": "PORT=${PORT:-${WEB_PORT:-3000}} next dev",
    "start": "PORT=${PORT:-${WEB_PORT:-3000}} next start"
  }
}
```

**For Python/FastAPI**:

Edit your main application file (e.g., `main.py`):
```python
import os
import uvicorn

# Add this where you run the server
if __name__ == "__main__":
    port = int(os.getenv("PORT", os.getenv("API_PORT", "8000")))
    uvicorn.run(app, host="0.0.0.0", port=port)
```

**For Django**:

Create or edit `manage.py` run command:
```bash
# Create a custom script or update package.json/start.sh:
python manage.py runserver 0.0.0.0:${PORT:-${API_PORT:-8000}}
```

---

#### 3. Register with Traefik Proxy

```bash
# Register your main application
add-proj myproject http://127.0.0.1:$WEB_PORT

# Register additional services if needed
add-proj myproject-api http://127.0.0.1:$API_PORT

# Verify registration
cat ~/dev-proxy/traefik_dynamic.yml
```

---

#### 4. Test Your Setup

```bash
# Start your development server
npm run dev  # or your framework's dev command

# Test direct access
curl http://localhost:$WEB_PORT

# Test proxy access
curl http://myproject.localtest.me

# Open in browser
open http://myproject.localtest.me
```

---

#### 5. Add to `.gitignore`

```bash
# Add to your .gitignore file
cat >> .gitignore << 'EOF'

# Deterministic port assignment (local only)
.envrc
start.sh
proxy_commands.sh
PORT_CONFIG.md
EOF
```

---

#### 6. Create `.env.example` for Team

Create a template for your team:
```bash
cat > .env.example << 'EOF'
# Local Development Ports
# Run 'portbase' to get your deterministic ports
WEB_PORT=4000
API_PORT=4001
DB_PORT=4002

# Production platforms (Railway, Vercel, Heroku) set PORT automatically
# Your code should check: PORT || WEB_PORT || default
EOF

# Commit this file
git add .env.example
```

---

## Part 3: Daily Usage

### Starting Your Project

```bash
# Navigate to your project
cd /path/to/your/project

# direnv automatically loads your ports
# (You'll see: "direnv: loading .envrc")

# Start your dev server
npm run dev  # or your start command

# Access via proxy
open http://myproject.localtest.me

# Or access directly
open http://localhost:$WEB_PORT
```

---

### Working with Multiple Projects

```bash
# Start first project
cd ~/projects/frontend
npm run dev  # Uses port 4387 (example)

# Open new terminal, start second project
cd ~/projects/backend
npm run dev  # Uses port 4821 (example, no conflict!)

# Both accessible via proxy:
# - http://frontend.localtest.me
# - http://backend.localtest.me
```

---

### Checking Your Ports

```bash
# Check what port this directory will use
cd /path/to/project
portbase

# Check what ports are currently exported
echo "Web: $WEB_PORT"
echo "API: $API_PORT"
echo "DB: $DB_PORT"

# Check if anything is using your port
lsof -i :$WEB_PORT
```

---

## Troubleshooting

### Issue: direnv not loading

**Symptom**: `$WEB_PORT` is empty when you `echo $WEB_PORT`

**Solution**:
```bash
# Check direnv status
direnv status

# Allow .envrc if needed
direnv allow

# Verify syntax
bash -n .envrc

# Check if direnv hook is installed
grep direnv ~/.zshrc  # or ~/.bashrc
```

---

### Issue: Port already in use

**Symptom**: "Error: listen EADDRINUSE: address already in use"

**Solution**:
```bash
# Find what's using the port
lsof -i :$WEB_PORT

# Kill the process (if appropriate)
kill -9 <PID>

# Or manually override the port in .envrc:
echo "export WEB_PORT=4500" >> .envrc
direnv allow
```

---

### Issue: Proxy not working

**Symptom**: `myproject.localtest.me` doesn't work

**Solution**:
```bash
# 1. Check if Traefik is running
docker compose -f ~/dev-proxy/docker-compose.yml ps

# 2. If not running, start it
cd ~/dev-proxy && docker compose up -d

# 3. If running, restart it
cd ~/dev-proxy && docker compose restart traefik

# 4. Check if your route is registered
cat ~/dev-proxy/traefik_dynamic.yml

# 5. Re-register your project
add-proj myproject http://127.0.0.1:$WEB_PORT

# 6. Check Traefik logs
docker compose -f ~/dev-proxy/docker-compose.yml logs -f traefik

# 7. Verify direct access works first
curl http://localhost:$WEB_PORT
```

**Remember**: Traefik is optional. Direct URLs (`localhost:PORT`) always work without it.

---

### Issue: Production deployment fails

**Symptom**: App works locally but crashes on Railway/Vercel/Heroku

**Solution**:
```bash
# Verify your code checks PORT first
grep -r "process.env.PORT" .  # Node.js
grep -r "os.getenv.*PORT" .   # Python

# Check binding address (must be 0.0.0.0, not localhost)
grep -r "listen.*localhost" .

# Correct pattern:
# PORT || WEB_PORT || default
# AND bind to 0.0.0.0
```

**Example fix for Node.js**:
```javascript
// Wrong
app.listen(3000);

// Wrong
const PORT = process.env.WEB_PORT || 3000;

// Correct
const PORT = process.env.PORT || process.env.WEB_PORT || 3000;
app.listen(PORT, '0.0.0.0');
```

---

## Quick Reference

### Key Commands
```bash
portbase                       # Get deterministic port
direnv allow                   # Activate .envrc
direnv status                  # Check direnv state
add-proj <name> <url>          # Register with proxy
lsof -i :$WEB_PORT             # Check port usage
docker compose -f ~/dev-proxy/docker-compose.yml ps  # Check Traefik
```

### Key URLs
- **Traefik Dashboard**: http://localhost:8080 (if Traefik running)
- **Proxy Entry Point**: http://localhost:9999 (if Traefik running)
- **Your Project (Proxy)**: http://yourproject.localtest.me (if Traefik running)
- **Your Project (Direct)**: http://localhost:$WEB_PORT (always works)

### Traefik Management
```bash
# Check if running
docker compose -f ~/dev-proxy/docker-compose.yml ps

# Start (run once, stays running)
cd ~/dev-proxy && docker compose up -d

# Stop (optional, when not needed)
cd ~/dev-proxy && docker compose down

# Restart (after config changes)
cd ~/dev-proxy && docker compose restart traefik
```

### Port Assignments
- `$WEB_PORT` = Base + 0 (frontend)
- `$API_PORT` = Base + 1 (backend)
- `$DB_PORT` = Base + 2 (database)
- `$DOCS_PORT` = Base + 3 (documentation)
- `$WS_PORT` = Base + 4 (websocket)

---

## Next Steps

✅ **System configured** - You're ready to develop!

**For team members**:
1. Share this guide with your team
2. Each developer runs system-wide setup once
3. They get the same ports automatically (same directories = same ports)

**For production deployment**:
- Your code already works with Railway, Vercel, Heroku
- No additional configuration needed
- The `PORT || WEB_PORT || default` pattern handles everything

**For more information**:
- [Technical Documentation](../port-assignment/README.md) - Architecture and internals
- [Scripts Source](/scripts/dev-proxy/) - Helper script implementations
