# Single-Server Operator Notes

These notes cover the boundary between host-run services, container platforms
and an edge proxy on a small Linux fleet.

| Note | Use it for | Boundary |
|---|---|---|
| [Deployment standards](deployment-standards.md) | systemd services, loopback binds, deploy users and backups | Host-run services |
| [Coolify onboarding](coolify-onboarding-checklist.md) | Container build, health, environment, networking and release checks | Coolify-managed containers |
| [Traefik file routing](traefik-file-routing.md) | One reviewed dynamic routing source for mixed services | Self-managed Traefik file provider |
| [Secrets hygiene](secrets-hygiene.md) | Least-privilege secret delivery and leak reduction for agent workflows | Complements, but does not replace, an organisation security policy |

Product behaviour changes. Check the current
[Coolify documentation](https://coolify.io/docs/),
[Traefik file-provider documentation](https://doc.traefik.io/traefik/providers/file/)
and [SQLite backup documentation](https://www.sqlite.org/backup.html) before
copying a configuration into production.

The examples use placeholders and conservative defaults. Test every service,
restore path and rollback on the target host.
