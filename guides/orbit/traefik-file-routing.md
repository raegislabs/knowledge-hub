# Traefik File-Based Routing

Use Traefik's file provider when one reviewed dynamic configuration should
describe routes for both host-run services and containers. If every service is
already represented by trustworthy Docker labels, keep the label provider and
avoid a second routing source.

## Choose the network shape first

The examples below assume one of these shapes:

1. Traefik runs as a host process and can reach host services on loopback.
2. Traefik runs in a Linux container with host networking and can therefore
   reach host loopback.

A normal bridged container cannot reach a host service through
`127.0.0.1`. In that container, loopback refers to Traefik itself.

Container applications should listen on `0.0.0.0` inside their container. If
Traefik uses host networking, publish an application port to host loopback:

```yaml
services:
  app:
    ports:
      - "127.0.0.1:8100:3000"
```

Do not combine host networking with Docker `ports` on the Traefik service;
host networking already exposes its listeners.

## Static configuration

Static configuration defines entry points, the file provider and ACME storage.
Keep ACME state outside Git and set its file mode to `0600`.

```yaml
# /etc/traefik/traefik.yml
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

providers:
  file:
    directory: /etc/traefik/dynamic
    watch: true

certificatesResolvers:
  le:
    acme:
      email: operator@example.com
      storage: /var/lib/traefik/acme.json
      httpChallenge:
        entryPoint: web
```

The HTTP challenge requires public port 80 to reach Traefik. Define the
resolver in static configuration and reference it from each TLS router.

Mount the parent dynamic directory into a container, not one individual file.
Some editors replace a file by moving a new inode into place, which can break a
single-file bind mount or its watch event.

## Dynamic route

```yaml
# /etc/traefik/dynamic/services.yml
http:
  routers:
    example:
      rule: "Host(`example.example.com`)"
      entryPoints:
        - websecure
      service: example
      middlewares:
        - secure-headers
      tls:
        certResolver: le

  middlewares:
    secure-headers:
      headers:
        contentTypeNosniff: true
        frameDeny: true
        referrerPolicy: strict-origin-when-cross-origin

  services:
    example:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8100"
        healthCheck:
          path: /health
          interval: 10s
          timeout: 3s
```

Replace the host rule, port and health path. DNS must point at the edge before
certificate issuance can succeed.

## Reusable controls

Rate limit a public API:

```yaml
http:
  middlewares:
    api-rate-limit:
      rateLimit:
        average: 50
        burst: 100
```

Restrict a router to a mesh VPN range:

```yaml
http:
  middlewares:
    vpn-only:
      ipAllowList:
        sourceRange:
          - "100.64.0.0/10"
```

Attach the middleware by name to the intended router. Confirm the client IP
Traefik sees before relying on an allowlist behind another proxy.

## Weighted cutover

Weighted services can move traffic between two healthy backends:

```yaml
http:
  routers:
    app:
      rule: "Host(`app.example.com`)"
      entryPoints: [websecure]
      service: app-active
      tls:
        certResolver: le

  services:
    app-blue:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8010"
    app-green:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:8100"
    app-active:
      weighted:
        services:
          - name: app-blue
            weight: 100
          - name: app-green
            weight: 0
```

Move a small share first, check health and errors, then complete or revert the
cutover. Keep old and new application versions compatible with the same
database state during the test.

## Apply and verify

1. Review the dynamic diff.
2. Save the file inside the watched directory.
3. Check Traefik logs for a parse or provider error.
4. Confirm the backend is listening on the expected host port.
5. Test the public route and health endpoint.

```bash
ss -ltn | grep ':8100'
curl --fail --show-error --silent https://example.example.com/health
```

File watching does not make every edit valid. A bad dynamic file may leave the
previous configuration active, so logs and an end-to-end request are required.

See Traefik's current
[file-provider](https://doc.traefik.io/traefik/providers/file/) and
[ACME](https://doc.traefik.io/traefik/https/acme/) documentation for the
version you operate.
