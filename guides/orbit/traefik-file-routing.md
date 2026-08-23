# Traefik File-Based Routing

How to run Traefik as a single edge proxy for a mixed fleet of systemd
services and Docker containers, with all routing in one version-controlled
file.

---

## Why file-based config, not Docker labels

The default Traefik setup discovers routes from Docker labels. On a server
that runs a mix of systemd services and containers, labels don't cover half
the fleet, and routing knowledge ends up scattered across compose files.
File-based config instead:

- Works identically for systemd services, containers, and anything else
  that can listen on a port
- Is one YAML file you can diff, review and back up in git
- Supports weighted services (blue/green) without orchestrator tricks
- Keeps routing alive even when the platform that manages containers
  (Coolify, Portainer) is itself broken — the edge doesn't depend on it

The trade-off: you maintain the file. The sections below are the whole
maintenance surface.

## Layout

| Component | Where |
|-----------|-------|
| Traefik | container or binary, exposing :80 and :443 |
| Dynamic config | `<config-root>/traefik-dynamic.yml` (watched, hot-reloads) |
| ACME certs | `<config-root>/acme/acme.json` (`chmod 600`) |

Static config via arguments:

```bash
--entrypoints.web.address=:80
--entrypoints.websecure.address=:443
--entrypoints.web.http.redirections.entryPoint.to=websecure
--entrypoints.web.http.redirections.entryPoint.scheme=https
--certificatesresolvers.le.acme.email=you@example.com
--certificatesresolvers.le.acme.storage=/etc/traefik/acme/acme.json
--certificatesresolvers.le.acme.httpchallenge=true
--certificatesresolvers.le.acme.httpchallenge.entrypoint=web
--entrypoints.websecure.http.tls.certResolver=le
--providers.file.directory=/etc/traefik/dynamic
--providers.file.watch=true
```

Do **not** enable the Docker provider. If it's on, label discovery silently
competes with your file.

## Adding a route

### Systemd service (or any loopback listener)

```yaml
http:
  routers:
    my-service:
      rule: "Host(`my-service.example.com`)"
      entryPoints:
        - websecure
      service: my-service
      tls:
        certResolver: le
      middlewares:
        - secure-headers

  services:
    my-service:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8100"
```

Certificates are issued automatically on first request; no per-domain
setup beyond the DNS record.

### Docker container

Map the container port to the host, then point the route at the host port
— same as above:

```yaml
# docker-compose.yaml
services:
  my-app:
    ports:
      - '8100:3000'   # host:container
```

### Rate limiting

Define once, attach to any router:

```yaml
http:
  middlewares:
    api-rate-limit:
      rateLimit:
        average: 50
        burst: 100
    login-rate-limit:
      rateLimit:
        average: 1
        burst: 5
```

### Restricting to a private network

If you run a mesh VPN (Tailscale and friends), internal dashboards can be
limited to its address range:

```yaml
http:
  routers:
    internal-service:
      rule: "Host(`internal.example.com`)"
      middlewares:
        - vpn-only

  middlewares:
    vpn-only:
      ipAllowList:
        sourceRange:
          - "100.64.0.0/10"   # CGNAT range used by the mesh
```

## Blue/green without an orchestrator

Run both versions on different loopback ports and switch traffic by
weight. Traefik hot-reloads the file, so "deploy" is a YAML edit:

```yaml
http:
  services:
    myapp-blue:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8010"

    myapp-green:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8100"

    myapp-active:
      weighted:
        services:
          - name: myapp-blue
            weight: 100
          - name: myapp-green
            weight: 0
```

Start the new version, move weight to it, watch health, keep or revert.
No downtime window, no container gymnastics.

## Keep a port registry

File-based routing means you assign host ports yourself. Keep a table in
the repo (`service | port | type`) so assignments never collide — or use
deterministic per-project ranges (see
[port-assignment-setup.md](port-assignment-setup.md) for the local
equivalent of the same idea).

## Applying and verifying changes

The file is watched; save it and Traefik reloads within seconds. No
restarts.

```bash
# Edge logs, if Traefik runs as a container
docker logs <traefik-container> --tail 20

# Route works end to end
curl -I https://my-service.example.com/health
```

If a route 404s: check the rule string backticks (YAML + Traefik quoting
bites everyone once), then check the service URL points at a host port
that is actually listening (`lsof -i :8100`).

## Notes

1. Docker labels do nothing here — the Docker provider is off; don't add
   them "just in case"
2. Containers must publish host ports for file routing to reach them
3. `acme.json` must stay `chmod 600` or Traefik refuses to start
4. The dynamic file belongs in version control — it *is* your edge
