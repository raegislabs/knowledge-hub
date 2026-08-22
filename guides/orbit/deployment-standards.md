# Single-Server Deployment Standards

Hard-won rules for running services on a small fleet of Linux servers
(droplets, VMs, bare metal) with agentic tooling in the loop. Every rule
below exists because something broke without it.

Written provider-agnostic: substitute your own hostnames, users and
addresses. Nothing here needs a specific vendor.

---

## 1. One service, one systemd unit

Every long-running service runs under systemd — not tmux, not `nohup`, not a
Docker container you can't inspect from the host.

```ini
# /etc/systemd/system/<service>.service
[Service]
User=deploy
WorkingDirectory=/var/www/<service>
ExecStart=/usr/bin/node dist/server.js
Restart=always
RestartSec=5

# Crash-loop protection: 3 rapid restarts stops instead of spinning
StartLimitBurst=3
StartLimitIntervalSec=60

# Hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ReadWritePaths=/var/www/<service>/logs
```

Why systemd and not a process manager you installed: the OS already owns
restart-on-boot, log rotation plumbing, and `journalctl` gives agents a
queryable log without extra tooling. An agent debugging at 2am can run
`systemctl status <service>` and `journalctl -u <service> -n 100` and get
structured answers.

## 2. Bind 127.0.0.1, terminate TLS at the edge

Application services listen on loopback only. A reverse proxy (Nginx,
Caddy, Traefik — pick one and standardise) owns the public ports, certificates,
and routing.

```
app listens on 127.0.0.1:<port>   ← never 0.0.0.0
        │
reverse proxy :443 ──── TLS, HTTP/2, rate limits, routing
        │
public DNS → proxy only
```

Benefits: one place for certificates, one place for access logs, one
firewall story (80/443 open, everything else closed), and no accidental
"the dev server is now internet-facing" incidents. Keep the proxy's dynamic
config in a file an agent can read and diff — config-as-code beats
click-ops when the change is made by something without a mouse.

## 3. Environment files, centralised and locked down

All secrets live in env files under one root, not scattered through service
directories:

```
/etc/<your-org>/env/<service>.<env>.env    # chmod 640, root:deploy
```

Rules:

- `chmod 640`, owned `root:deploy` — the service user can read, nobody else
- One file per service per environment; the systemd unit loads it via
  `EnvironmentFile=`
- The directory is the deployment contract: `ls /etc/<your-org>/env/` is the
  inventory of everything running
- Back up this directory encrypted; it *is* the keys to the kingdom
- For higher-stakes setups, move the SSot into a secrets manager (see
  [secrets-hygiene.md](secrets-hygiene.md)) and keep env files generated,
  never hand-edited

## 4. A deploy user that isn't root

Agents and CI deploy as a dedicated user with exactly the rights needed:
write to service directories, restart its own units (via a sudo allowlist),
read its own env files. Root stays for humans on the console.

```sudoers
deploy ALL=(root) NOPASSWD: /bin/systemctl restart <service>, /bin/systemctl status <service>*
```

The failure mode this prevents: a hallucinated command in an agentic deploy
runs as root because the deploy pipeline happened to be logged in as root.

## 5. Backups with retention, tested

- Database dumps on a schedule (cron or systemd timers — operator-owned,
  not a CI provider)
- Timestamped files with retention (`--keep-days 7` beats "we'll clean it up
  later")
- For SQLite: checkpoint WAL before copying (`PRAGMA wal_checkpoint(TRUNCATE);`)
  or your backup is a torn read
- Monthly: actually restore one. An untested backup is a rumour.

The backup scripts in `tools/db-safe/` of this repo implement the pattern.

## 6. Monitoring that pages a human

An uptime monitor with alerts (Uptime Kuma self-hosted, or a hosted
equivalent) watching the public endpoints *and* one internal heartbeat per
service. Agents can check status; only humans should be paged.

## 7. Automation stays operator-owned

Deployment hooks, backup schedules and sync jobs run from machines you
control via launchd, systemd timers or cron — not from a hosted CI provider.
Cost is one reason; the better reason is that "the pipeline that can deploy
to production" should not have credentials living in a third-party SaaS you
half-remember configuring. If a hosted CI is genuinely required, scope its
credentials to exactly one target and rotate them on a schedule.

---

## The checklist (pin this)

- [ ] Service runs under systemd with crash-loop protection
- [ ] Listens on 127.0.0.1 only; TLS terminates at the reverse proxy
- [ ] Env file in the central directory, `chmod 640`, loaded by the unit
- [ ] Deploys happen as a non-root user with a sudo allowlist
- [ ] Backups run on a timer, with retention, and one was restored this quarter
- [ ] Uptime monitoring covers public endpoints and internal heartbeats
- [ ] No deploy credentials live in a hosted CI provider
