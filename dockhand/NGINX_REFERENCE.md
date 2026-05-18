# Dockhand Home Assistant Addon: Nginx Notes

This document captures nginx troubleshooting and configuration decisions made while adapting Dockhand to Home Assistant addon runtime constraints.

## Why This Was Needed

The addon failed to start nginx with:

`chown("/var/lib/nginx/body", 33) failed (1: Operation not permitted)`

This happened because Home Assistant addon containers are more restricted than a typical local Docker run, and nginx defaults can attempt ownership/path operations that are denied.

## Key Problems Encountered

1. nginx startup failed on default temp/body path permissions.
2. After moving temp paths to `/tmp`, nginx failed because parent directories were missing:
    - `mkdir() "/tmp/nginx/client_temp" failed (2: No such file or directory)`
3. UI became slow/unresponsive after aggressive Connection-header changes.
4. In real HA runtime, `user root;` caused:
    - `initgroups(root, 0) failed (1: Operation not permitted)`
5. Removing `user root;` entirely caused a different failure:
    - `chown("/tmp/nginx/client_temp", 65534) failed (1: Operation not permitted)`
    - nginx defaulted to `nobody` (uid 65534) and attempted to chown temp dirs to that user, also blocked.
6. Attempting to start nginx via `s6-setuidgid dockhand` failed in HA runtime:
    - `unable to set supplementary group list: Operation not permitted`

## Current Decisions (What We Kept)

### 1) Start nginx as root process, with `user root;`, `master_process off;`, and `worker_processes 1`

- Service launch uses:
    - `exec nginx -g "daemon off;"`

- `nginx.conf` currently uses:
    - `user root;`
    - `master_process off;`
    - `worker_processes 1;`

Reason: both directives are required together.

- `user root;` is needed so nginx does not try to chown `/tmp/nginx/*` temp dirs to a default unprivileged user (e.g. `nobody`, uid 65534), which fails in HA addon containers.
- `master_process off;` prevents nginx from forking worker processes. Worker forking triggers `initgroups(root, 0)` to set up supplementary groups — a `CAP_SETGID` syscall that is blocked in HA addon containers, causing `[emerg] initgroups(root, 0) failed (1: Operation not permitted)`.

With both in place, nginx runs in single-process mode as root with no syscall failures.

Note: `master_process off;` is a single-process debug mode. For a single-user HA addon it is perfectly adequate. Websocket and stream proxy behavior is unaffected — those are handled by proxy directives, not worker count.

### 2) Use `/tmp/nginx/*` for nginx temp and log paths

Reason: avoids restricted default paths that previously triggered startup failures in addon context.

Configured temp paths:

- `client_body_temp_path /tmp/nginx/client_temp;`
- `proxy_temp_path /tmp/nginx/proxy_temp;`
- `fastcgi_temp_path /tmp/nginx/fastcgi_temp;`
- `uwsgi_temp_path /tmp/nginx/uwsgi_temp;`
- `scgi_temp_path /tmp/nginx/scgi_temp;`

Startup script creates required folders before nginx launch.

The service script also includes `# shellcheck shell=bash` because `/usr/bin/with-contenv bashio` shebang is not recognized by ShellCheck by default.

### 3) Stream/heartbeat endpoints stay unbuffered and non-upgrade

For `location ~ ^/api/(events$|.+/stream$)`:

- `proxy_buffering off;`
- `proxy_request_buffering off;`
- `add_header X-Accel-Buffering no;`
- `proxy_set_header Upgrade "";`
- `proxy_set_header Connection "";`

Reason: these endpoints are long-lived stream/heartbeat style traffic and should not be treated as websocket upgrades.

### 4) Websocket Connection mapping retained with safe fallback

In nginx `http` block:

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      '';
}
```

In `location /`:

- `proxy_set_header Upgrade $http_upgrade;`
- `proxy_set_header Connection $connection_upgrade;`

Reason:

- only sends `Connection: upgrade` when upgrade is requested
- does not force `Connection: close` on normal HTTP traffic
- avoids unnecessary keep-alive degradation

## Items Considered But Not Adopted Fully

Portainer addon nginx patterns were reviewed.

Adopted ideas:

1. Use explicit upgrade handling pattern.
2. Allow larger body size (`client_max_body_size 0;`).

Not copied directly:

1. `resolver/upstream` indirection (not needed for direct `127.0.0.1:3000` proxying).
2. Additional CSP/frame overrides (not required by current ingress shim approach).
3. Global gzip enablement (kept off to avoid stream/latency edge cases unless needed).

## Clarification: `$http_connection` vs `$connection_upgrade`

- `$http_connection` is raw client header input (can vary widely).
- `$connection_upgrade` is controlled behavior from `map`.

Current chosen behavior uses mapped upgrade handling with empty fallback to avoid forcing `close` for normal requests.

## First Install Performance (Expected Warmup)

Observed behavior in local dev:

1. First install/start can feel slow or temporarily unresponsive.
2. After initialization completes, performance becomes normal/fast.

Likely causes during cold start:

1. Initial key generation and app setup.
2. First Docker metadata scans and cache priming.
3. Filesystem and container-layer warmup in dev environments.

Interpretation:

1. If slowness is mostly first-run and later restarts are fast, this is expected warmup behavior.
2. If slowness persists across warm restarts, investigate nginx proxy behavior and upstream latency.

## If UI Becomes Slow Again

1. Re-check that non-upgrade traffic is not being forced to `Connection: close`.
2. Re-check stream endpoint buffering directives remain disabled.
3. Inspect nginx access/error logs under `/tmp/nginx/`.
4. Confirm Dockhand upstream (`127.0.0.1:3000`) response times independently of ingress.

## Quick Validation Checklist

1. Addon starts and ingress is reachable.
2. UI loads and responds normally.
3. Terminal/live-log websocket features still work.
4. Stream endpoints stay connected without frequent disconnect noise.
5. `initgroups(root, 0)` should no longer appear; it was resolved by adding `master_process off;` to `nginx.conf`. If it reappears, check that both `user root;` and `master_process off;` are present.
