# Dockhand

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[Dockhand](https://github.com/Finsys/dockhand) is a modern, lightweight Docker management UI - a streamlined alternative to Portainer. Manage your containers, images, volumes, and networks directly from your Home Assistant sidebar.

> **⚠️ WARNING: Protection Mode must be disabled**
>
> Dockhand requires direct access to the Docker socket (`/var/run/docker.sock`).
> You **must disable "Protection Mode"** in the app settings before starting Dockhand.
> Go to **Settings → Apps → Dockhand** and toggle off "Protection Mode".
> Failure to do so will prevent the app from starting.

## Features

- Browse and manage containers, images, volumes, and networks
- Start, stop, restart, and remove containers
- Scheduled image updates and pruning to prevent running out of disk space
- View real-time container logs and stats
- Integrated terminal access to running containers
- Persistent data stored in `/data` (SQLite database)
- Accessible via HA Ingress sidebar — no separate login required

## Architecture

| Architecture | Supported |
| ------------ | --------- |
| aarch64      | ✅        |
| amd64        | ✅        |

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
