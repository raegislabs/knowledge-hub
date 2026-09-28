# Coolify Service Onboarding Checklist

A release checklist for a containerised service on a self-hosted Coolify
instance. Use Coolify's current documentation as the authority for product
settings and supported build modes.

## 1. Build a production container

- [ ] The Dockerfile builds from a clean checkout.
- [ ] The runtime image contains only production dependencies.
- [ ] The process handles SIGTERM and exits within the deployment grace period.
- [ ] The process runs as a non-root user unless a documented requirement
      prevents it.
- [ ] Persistent data uses a named volume or external service.
- [ ] A health check tests a real dependency boundary, not only that the process
      exists.

Example health check:

```dockerfile
HEALTHCHECK --interval=10s --timeout=3s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/health || exit 1
```

Use a tool that exists in the runtime image. A missing `curl` or `wget` makes a
healthy application look unhealthy.

## 2. Bind correctly inside the container

- [ ] The application listens on `0.0.0.0:<internal-port>` inside the
      container.
- [ ] The Coolify port setting matches that internal port.
- [ ] The service does not publish a public host port.
- [ ] If an operator explicitly needs a host mapping, it is bound to loopback:
      `127.0.0.1:<host-port>:<container-port>`.

`127.0.0.1` inside a container is the container itself. Setting
`HOST=127.0.0.1` prevents Coolify's proxy network from reaching the
application.

## 3. Declare configuration and secrets

- [ ] `.env.example` contains variable names and safe placeholders only.
- [ ] Every required variable is present in Coolify.
- [ ] Secret values are marked as secrets and are scoped to this service.
- [ ] Compose deployments fail when a required variable is absent.

```yaml
services:
  app:
    environment:
      DATABASE_URL: "\${DATABASE_URL:?DATABASE_URL is required}"
      APP_ENV: "\${APP_ENV:-production}"
```

- [ ] No real `.env` file is committed.
- [ ] Logs do not print environment objects, tokens or connection strings.

## 4. Configure the resource in Coolify

- [ ] Correct repository, branch and base directory selected.
- [ ] Build method matches the repository.
- [ ] Internal port and health state are visible in the resource.
- [ ] CPU and memory limits are set from measured needs.
- [ ] Restart behaviour is documented.
- [ ] A manual deployment succeeds before any automatic trigger is enabled.

If a Git-host webhook triggers deployment, the receiver should be your own
Coolify instance. Do not add a GitHub Actions deployment workflow or store
production credentials in a hosted runner.

## 5. Configure domain and TLS

For a public service:

- [ ] DNS points to the intended server.
- [ ] Domain is attached to the correct Coolify resource.
- [ ] TLS certificate is valid.
- [ ] HTTP redirects to HTTPS.
- [ ] Health endpoint returns the expected status through the public domain.
- [ ] Proxy and application logs agree on the request.

For an internal service:

- [ ] No public domain or public host port is configured.
- [ ] Consumers use the service name on the intended Docker network.
- [ ] Network membership is limited to services that need access.

## 6. Handle database changes

- [ ] Backup or restore point exists before a destructive migration.
- [ ] Migration command is idempotent or guarded against a second run.
- [ ] Only one release instance performs the migration.
- [ ] Application code remains compatible during a rolling replacement.
- [ ] Rollback behaviour is written down and tested on staging.

## 7. Prove the release path

- [ ] New container becomes healthy before traffic moves.
- [ ] Existing requests finish during shutdown.
- [ ] A small release produces no unexpected 5xx responses.
- [ ] Application, proxy and database logs contain no new errors.
- [ ] Rollback returns the previous version to healthy state.
- [ ] Operator inventory records the service, owner, domain, internal port,
      data stores, backup job and alert route.

Recheck the
[Coolify Docker Compose](https://coolify.io/docs/knowledge-base/docker/compose)
and [health-check](https://coolify.io/docs/knowledge-base/health-checks)
documentation when the platform version changes.
