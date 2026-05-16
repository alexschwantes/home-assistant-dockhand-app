# Dockhand — Documentation

## Installation

1. Add this repository to your Home Assistant instance via **Settings → Apps → Install app → ⋮ → Repositories**.
2. Find **Dockhand** in the App store and click **Install**.
3. Wait for the image to download and build.

## Disabling Protection Mode

Dockhand requires access to the Docker socket (`/var/run/docker.sock`) to manage containers.
Home Assistant's "Protection Mode" blocks this by default.

**You must disable Protection Mode before starting the app:**

1. Go to **Settings → Apps → Dockhand**.
2. Scroll down to the **Protection Mode** toggle.
3. Switch it **off**.
4. A warning will appear — confirm you understand the security implications.
5. Click **Start** to start Dockhand.

> **Security note:** Disabling Protection Mode grants the container full access to the Docker
> daemon. This is the same security posture required by Portainer. Only disable if you trust
> the workload running in this container.

## Starting the App

After disabling Protection Mode, click **Start** on the Dockhand app page.

Check the **Log** tab to confirm that:

- The protection check passes
- Dockhand starts on port 3000
- nginx ingress proxy starts on port 8099

## Accessing the UI

Once started, a **Dockhand** entry with a Docker icon (`mdi:docker`) will appear in your
Home Assistant sidebar. Click it to open the Dockhand UI via Ingress — no additional login
is required.

## Data Persistence

Dockhand stores its SQLite database and application data in the `/data` directory, which is
mapped to persistent Home Assistant storage. Your data survives app restarts and updates.

## Ports

Direct port access on `3000/tcp` is disabled. All access is via the HA Ingress proxy on
port 8099. This means Dockhand is only reachable through your Home Assistant instance.

## Troubleshooting

- **App fails to start with "unprotected" error**: Protection Mode is still enabled.
  Follow the steps above to disable it.
- **UI loads but containers are not visible**: Confirm the Docker socket (`/var/run/docker.sock`)
  is accessible from within the container. Check the app logs for socket-related errors.
- **"Permission denied - check socket permissions" when adding HA environment**:
  restart the app so startup can remap the `dockhand` user to the socket's group ID.
  Then retry with Unix socket path `/var/run/docker.sock`.
- **Assets or routing issues**: Dockhand may need a `BASE_PATH` environment variable for
  sub-path aware routing if Ingress path rewriting causes issues. Check the Dockhand
  documentation for available environment variables.
