# Dockhand — Documentation

## Installation

1. Add this repository to your Home Assistant instance via **Settings -> Apps -> Install app -> ⋮ -> Repositories**.
1. Click **+ Add** and paste the repository URL https://github.com/alexschwantes/home-assistant-dockhand-app into the field and click **Add**
1. Find **Dockhand** in the App store and click **Install**.

## Running Dockhand App

> **⚠️ Protection Mode must be disabled**
>
> Dockhand requires direct access to the Docker socket (`/var/run/docker.sock`).
> You **must disable "Protection Mode"** in the app settings before starting Dockhand.
> Go to **Settings → Apps → Dockhand** and toggle off "Protection Mode".
> Failure to do so will prevent the app from starting.

> **Security note:** Disabling Protection Mode grants the container full access to the Docker
> daemon. This is the same security posture required by Portainer. Only disable if you trust
> the workload running in this container.

Dockhand stores its SQLite database and application data in the `/data` directory, which is
mapped to persistent Home Assistant storage. Your data survives app restarts and updates.

## Accessing Dockhand

Dockhand can be accessed via the Dockhand App page, or you can enable the app setting to "Show in sidebar" which will add a new menu to the sidebar:

<img src="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/refs/heads/6.x/svgs/brands/docker.svg" width="20" height="20">&nbsp;&nbsp;&nbsp;**Dockhand**

Direct access to Dockhand outside of Home Assistance is disabled.

> **Note:** Direct access to Dockhand outside of Home Assistance is disabled.

## First Use / Configuration

You first need to add the local Home Assistant Environment:

1. From the Dockhand Dashboard click go to settings
1. Click **+ Add environment**
1. Enter a **name** and click **+ Add**

> **Worthwhile setting:** Under the **Updates** tab for the environment, enable **automatic image pruning**. This will schedule a clean up of old images to prevent Home Assistant running out of space.

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

## Known Issues

- **Ingress stream disconnect noise when navigating between pages**:
  Long-lived API stream requests can log transient disconnects when a page is closed, refreshed, or changed. This results in the following Supervisor Logs:
    - `Stream error with http://<addon-ip>:8099/api/...: Cannot write to closing transport`

    This is benign as the UI remains responsive and streams reconnect when returning to the page.
