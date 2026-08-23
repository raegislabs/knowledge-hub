# Self-Host Platform Onboarding Checklist (Coolify)

Bring a new service onto a self-hosted Coolify installation without
forgetting the boring steps. Written for Coolify; the shape transfers to
any PaaS-on-your-own-server (Dokku, CapRover, Portainer + Compose).

---

## 1. Repository and build

- [ ] Repository exists for the service.
- [ ] `Dockerfile` builds a production image locally (no missing dependencies).
- [ ] `docker-compose.yml` (if used) defines:
  - [ ] Single app service with the correct internal port.
  - [ ] Health check configured (`/health` or equivalent).
  - [ ] Resource limits set (CPU and memory).
  - [ ] Named volumes for persistent data (if needed).
- [ ] `.env.example` added with all required variables (no real secrets).
- [ ] `README.md` covers purpose, env vars, and health endpoints.

## 2. Platform project

- [ ] Project created or selected (kebab-case, product-aligned).
- [ ] Application resource created via the Git integration.
- [ ] Correct repository and branch selected (`main` → production,
      `develop` → staging if applicable).
- [ ] Build method (Dockerfile / buildpack) and base directory validated.

## 3. Deployment strategy and health

- [ ] Zero-downtime strategy selected: rolling (stateless) or
      blue/green (critical services).
- [ ] Health check configured in the platform:
  - [ ] Path matches the application (`/health` or `/api/health`).
  - [ ] Interval ~10 seconds.
  - [ ] Healthy threshold ≥ 2 consecutive successes.
  - [ ] Graceful shutdown timeout ≥ 30 seconds.
- [ ] The application actually implements the endpoint.

## 4. Environment and secrets

- [ ] Every variable from `.env.example` created in the platform.
- [ ] Sensitive variables marked as secrets.
- [ ] No real `.env` files committed to Git.
- [ ] Standard variables set: `HOST=127.0.0.1`, `PORT=<port>`,
      `ENVIRONMENT=production`, `LOG_LEVEL=INFO`.
- [ ] `DATABASE_URL` set if the service uses a database.
- [ ] Notification webhook URL set if deployment alerts are wanted.

## 5. Networking and TLS

Public services:

- [ ] DNS record points at the server's reserved IP.
- [ ] Domain added in the platform; certificate issued (Let's Encrypt).
- [ ] HTTP redirects to HTTPS.
- [ ] Health endpoint reachable at `https://<domain>/health`.

Internal-only services:

- [ ] No domain configured.
- [ ] Reachable from other containers via the shared Docker network.

## 6. Database (if applicable)

- [ ] Database created, internal-only (no public port).
- [ ] Connection string copied into service environment.
- [ ] Migrations run successfully on first deploy.

## 7. Webhooks and auto-deploy

- [ ] Auto-deploy on push enabled for the chosen branches.
- [ ] Webhook deliveries show success in the Git host.
- [ ] One manual deployment has succeeded.

## 8. Notifications

- [ ] Webhook (Slack/other) created and stored as a secret.
- [ ] Deployment started / succeeded / failed events configured.
- [ ] A test deployment actually sends the messages.

## 9. First deploy validation

- [ ] Build logs clean; container starts.
- [ ] Status `Running`, health indicator green.
- [ ] Health endpoint returns `200 OK`.
- [ ] Startup logs look sane in the log viewer.

## 10. Zero-downtime check

- [ ] Trivial change pushed to the auto-deploy branch.
- [ ] New version passes health before old container stops.
- [ ] No 5xx responses during the deployment window.

## 11. Documentation and inventory

- [ ] README updated: architecture, dependencies, env vars, endpoints.
- [ ] Central service inventory updated (one table somewhere: service,
      port, type — see the port registry note in
      [traefik-file-routing.md](traefik-file-routing.md)).

All boxes checked = onboarded.
