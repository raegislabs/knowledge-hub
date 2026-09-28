# Single-Server Deployment Standards

Rules for host-run services on a small Linux fleet. Containers managed by
Coolify or another platform have a different network boundary; see the
[Coolify checklist](coolify-onboarding-checklist.md).

## 1. Give every host service a systemd unit

Use the operating system's service manager for restart policy, startup order,
resource limits and logs.

```ini
# /etc/systemd/system/<service>.service
[Unit]
Description=<service>
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
Type=simple
User=deploy
Group=deploy
WorkingDirectory=/var/www/<service>
EnvironmentFile=/etc/<your-org>/env/<service>.prod.env
ExecStart=/usr/bin/node dist/server.js
Restart=on-failure
RestartSec=5
TimeoutStopSec=30

NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/www/<service>/logs

[Install]
WantedBy=multi-user.target
```

`StartLimitIntervalSec` and `StartLimitBurst` belong in `[Unit]`.
`ReadWritePaths` must list every path the process legitimately writes. Test
hardening options against the real service before enabling the unit.

```bash
sudo systemd-analyze verify /etc/systemd/system/<service>.service
sudo systemctl daemon-reload
sudo systemctl enable --now <service>
systemctl status <service>
journalctl -u <service> -n 100 --no-pager
```

## 2. Keep host application ports on loopback

A host-run application listens on `127.0.0.1:<port>`. The edge proxy owns
public ports, TLS and routing.

```text
public DNS -> edge proxy :443 -> 127.0.0.1:<service-port>
```

This rule applies to host processes. A process inside a container normally
listens on `0.0.0.0` inside that container so the container network can reach
it. Do not publish that container port publicly. If a host mapping is required,
bind the mapping to loopback:

```yaml
ports:
  - "127.0.0.1:8100:3000"
```

## 3. Keep service environment files in one protected root

```text
/etc/<your-org>/env/<service>.<environment>.env
```

- Own each file as `root:deploy` with mode `0640`.
- Give each service its own file and credentials.
- Load the file with `EnvironmentFile=`.
- Keep the writable source in a secrets manager where possible. Generate the
  host file and do not edit it by hand.
- Encrypt backups of this directory and restrict restore access.

## 4. Deploy through a restricted account

Run services and deployment commands as a dedicated user. Give it only the
specific privileged commands it needs.

```sudoers
deploy ALL=(root) NOPASSWD: /bin/systemctl restart <service>
deploy ALL=(root) NOPASSWD: /bin/systemctl status <service>
```

Use exact command paths from `command -v systemctl` on the target host.
Avoid wildcard-heavy sudo rules. Root remains an operator account, not the
default automation identity.

## 5. Back up databases through a consistent interface

For server databases, use the database's supported dump or backup command.
For SQLite, prefer the
[online backup API](https://www.sqlite.org/backup.html) or the CLI `.backup`
command while the database is live.

```bash
sqlite3 /var/lib/<service>/app.db ".backup '/var/backups/<service>/app-$(date +%F).db'"
```

If an operating procedure uses a WAL checkpoint, abort the backup when the
checkpoint fails. Do not continue with a raw copy. A raw copy is safe only when
the database is stopped or when the database, WAL and shared-memory files are
captured as one consistent snapshot.

- Schedule backups with a systemd timer or cron on an operator-owned host.
- Use timestamped files and explicit retention.
- Encrypt off-host copies.
- Restore a sample on a schedule and record the result.

## 6. Monitor from the user's side

Check the public HTTPS endpoint and a service-specific health endpoint.
Alert a human when availability or data freshness breaches a stated limit.
Keep alert delivery independent from the service being monitored.

## 7. Keep release automation operator-owned

Run deployment hooks, backup schedules and release gates on machines you
control through launchd, systemd timers or cron. Do not place production
credentials in GitHub Actions or another hosted CI runner.

## Release checklist

- [ ] systemd unit verifies and stops cleanly
- [ ] crash-loop limits are in `[Unit]`
- [ ] host service listens on loopback only
- [ ] edge proxy terminates TLS
- [ ] environment file is service-specific and mode `0640`
- [ ] deployment account has an exact sudo allowlist
- [ ] backup uses a consistent database interface
- [ ] a recent restore has succeeded
- [ ] public health and freshness checks alert a human
- [ ] release gate and scheduler are operator-owned
