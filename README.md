<p align="center" style="margin-top: 10px; margin-bottom: 10px;">
  <a href="https://www.home-assistant.io/"><img src="home-assistant-logo.svg" alt="Home Assistant Logo" height="60" style="vertical-align:middle; margin-right:20px;"/></a>
  <span style="font-size:2rem; vertical-align:middle; margin: 0 16px;">➕</span>
  <a href="https://github.com/Finsys/dockhand"><img src="dockhand-logo.webp" alt="Dockhand Logo" height="60" style="vertical-align:middle; margin-left:20px;"/></a>
</p>

# Home Assistant Dockhand App

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

Home Assistant app repository for [Dockhand](https://github.com/Finsys/dockhand) - a modern, lightweight Docker management UI.

This app replaces Portainer in Home Assistant for managing all your docker images with a more modern UI. The main feature it has is that it can be configured to auto prune images so your disk doesn't fill up over time.

# Installation

[![](https://img.shields.io/badge/status-experimental-orange?style=for-the-badge)](https://github.com/alexschwantes/home-assistant-dockhand-app)

> **⚠️ Experimental Stage**
>
> This project is in an **experimental** stage. Features and behavior may change at any time. Use with caution and provide feedback or issues if you encounter problems.

---

This will install Dockhand on your Home Assistant and allow you to manage everything from within HASS.

## Automatic Install

1. Automatic: click link to add to your home assistance

    [![Open your Home Assistant instance and show the app store with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_store.svg)](https://my.home-assistant.io/redirect/supervisor_store/?repository_url=https%3A%2F%2Fgithub.com%2Falexschwantes%2Fhome-assistant-dockhand-app)

    [![Open your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Falexschwantes%2Fhome-assistant-dockhand-app)

1. Search for `Dockhand` in the apps and click install

## Manual Install

1. Open Home Assistant
1. Go to Settings -> Apps -> Install app
1. Click the three dots in the top-right corner and select Repositories
1. Click Add and paste the repository URL https://github.com/alexschwantes/home-assistant-dockhand-app into the field and click "Add"
1. Search for `Dockhand` in the apps and click install

# Configuration

None yet.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[releases-shield]: https://img.shields.io/github/release/alexschwantes/home-assistant-dockhand-app.svg
[releases]: https://github.com/alexschwantes/home-assistant-dockhand-app/releases
[project-stage-shield]: https://img.shields.io/badge/project%20stage-experimental-yellow.svg
