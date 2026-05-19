<p align="center">
  <a href="https://www.home-assistant.io/"><img src="home-assistant-logo.svg" alt="Home Assistant Logo" height="60" /></a>
  &nbsp;&nbsp;<img src="plus-icon.svg" alt="Plus" height="30" />&nbsp;&nbsp;
  <a href="https://github.com/Finsys/dockhand"><img src="dockhand/logo.png" alt="Dockhand Logo" height="60" /></a>
</p>

# Home Assistant Dockhand App

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Home Assistant App repository for [Dockhand](https://github.com/Finsys/dockhand) - a modern, lightweight Docker management UI - a streamlined alternative to Portainer. Manage your containers, images, volumes, and networks directly from your Home Assistant sidebar.

This app replaces Portainer in Home Assistant for managing all your docker images with a more modern UI. One great feature is that it can be configured to auto prune images so your disk doesn't fill up over time.

![Dockhand Environment in Home Assistant](https://github.com/user-attachments/assets/666579ea-7e62-4c97-805b-531531225a5f)
![Dockhand Containers in Home Assistant](https://github.com/user-attachments/assets/e8405ec3-55e6-4f6a-9f6e-f5f6f61f5e3e)

## Installation

This will install Dockhand on your Home Assistant and allow you to manage everything from within HASS.

### Automatic Install

1.  Click the link below to automatically add repository for Dockhand

    [![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_addon/?repository_url=https%3A%2F%2Fgithub.com%2Falexschwantes%2Fhome-assistant-dockhand-app&addon=469b7386_dockhand)

1.  Click `Install` to install Dockhand App

### Manual Install

1. Add this repository to your Home Assistant instance via **Settings -> Apps -> Install app -> ⋮ -> Repositories**.
1. Click **+ Add** and paste the repository URL `https://github.com/alexschwantes/home-assistant-dockhand-app` into the field and click **Add**
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

> **Note:** Direct access to Dockhand outside of Home Assistance is disabled.

## First Use / Configuration

You first need to add the local Home Assistant Environment:

1. From the Dockhand Dashboard click go to settings
1. Click **+ Add environment**
1. Enter a **name** and click **+ Add**

> **Worthwhile setting:** Under the **Updates** tab for the environment, enable **automatic image pruning**. This will schedule a clean up of old images to prevent Home Assistant running out of space.

## Known Issues

- **MINOR: Need to manually refresh page after enabling Dockhand authentication:**

    Should you wish to enable user authentication within Dockhand, you are not immediately redirected to the login page. You will need to refresh the page to see the Dockhand login screen. This only happens the first time when enabling authentication.

- **MINOR: Ingress stream disconnect noise when navigating between pages**:

    Long-lived API stream requests can log transient disconnects when a page is closed, refreshed, or changed. This results in the following Supervisor Logs:
    - `Stream error with http://<addon-ip>:8099/api/...: Cannot write to closing transport`

    This is benign as the UI remains responsive and streams reconnect when returning to the page.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[releases-shield]: https://img.shields.io/github/release/alexschwantes/home-assistant-dockhand-app.svg
[releases]: https://github.com/alexschwantes/home-assistant-dockhand-app/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-development-yellowgreen.svg
