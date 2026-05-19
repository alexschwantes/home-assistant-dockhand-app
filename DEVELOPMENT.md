# Development Guide

## Release Guide

For release automation options and the recommended workflow, see [RELEASE.md](RELEASE.md).

## Local Dev Workflow

The devcontainer includes a local HA supervisor instance. Use VS Code tasks (`.vscode/tasks.json`) for the standard iteration cycle:

> **⚠️ Important:** If you want to guarantee Home Assistant builds from your local `Dockerfile` source while iterating, temporarily comment `image:` in `dockhand/config.yaml`.
>
> With `image:` present, Supervisor may use registry image flows in some install/update paths, which can make local changes appear to be ignored.

```bash
# Full rebuild from source + start + tail logs
ha apps rebuild --force "local_dockhand"; ha apps start "local_dockhand"; ha apps logs -f "local_dockhand"
```

For quick build validation without the supervisor:

```bash
docker build -t dockhand-local ./dockhand
```

## Testing on a Real HA Instance

The local devcontainer does **not** replicate the full security constraints of a real HA instance (see [AGENTS.md](AGENTS.md#local-dev-vs-real-ha-security-posture-gap)). Changes to nginx config, AppArmor, or startup scripts must be verified on a real instance.

Three options for deploying a locally-built image to a real HA instance:

---

### Option A — Copy Source + Build on Device

Best for: one-off testing, no network setup, HA OS or Supervised installs.

The HA supervisor builds the image on the HA host from the Dockerfile — same as local dev but under real security constraints.

> **⚠️ Important:** For predictable source-based behavior in this option, comment `image:` while testing local changes, then restore it before release.

> Note: `rsync` is not installed on HA OS. Use `scp`, tar-over-SSH, or Samba instead.

**Via scp over SSH:**

```bash
scp -r /mnt/supervisor/addons/local/home-assistant-dockhand-app/. \
  root@homeassistant.local:/addons/local/home-assistant-dockhand-app/
```

**Via tar over SSH** (recommended — single stream, no temp files, no rsync needed on remote):

Run the **"Deploy to Real HA (tar over SSH)"** VS Code task, or run manually:

```bash
tar czf - -C /mnt/supervisor/addons/local/home-assistant-dockhand-app --exclude='.git' . \
  | ssh root@homeassistant.local "tar xzf - -C /addons/local/home-assistant-dockhand-app" \
  && ssh root@homeassistant.local \
    "ha apps rebuild --force local_dockhand && ha apps start local_dockhand && ha apps logs -f local_dockhand"
```

The task prompts for the HA hostname (defaults to `homeassistant.local`), copies the source, rebuilds, starts, and tails logs in one step.

On **Windows**, skip all of the above — just copy/sync the folder in Explorer to `\\homeassistant\addons\local\home-assistant-dockhand-app`.

Then on the HA host, install or rebuild the local addon:

```bash
ha apps install local_dockhand
# or, if already installed:
ha apps rebuild --force local_dockhand && ha apps start local_dockhand
```

**Limitations:** builds on-device (slower on low-power HA hardware).

---

### Option B — Local Docker Registry

Best for: rapid iteration on a real HA instance; most closely mirrors GHCR production workflow.

**One-time setup:**

1. Start a local registry on the dev/host machine (outside devcontainer):

    ```bash
    docker run -d -p 5000:5000 --restart=always --name local-registry registry:2
    ```

2. Allow the insecure registry on the HA host. On HA Supervised/Linux hosts, add to `/etc/docker/daemon.json`:

    ```json
    {
        "insecure-registries": ["<host-machine-ip>:5000"]
    }
    ```

    Then restart Docker: `systemctl restart docker`

    > On Home Assistant OS, direct access to `daemon.json` may not be available — use Option A or C instead.

3. Set the `image` field in `dockhand/config.yaml` to point to your registry:
    ```yaml
    image: <host-machine-ip>:5000/dockhand:{arch}
    ```

**Per-iteration workflow:**

```bash
# Build and push
docker build -t <host-machine-ip>:5000/dockhand:amd64 ./dockhand
docker push <host-machine-ip>:5000/dockhand:amd64

# On HA host: pull and restart
ha apps stop local_dockhand
ha apps update local_dockhand
ha apps start local_dockhand
```

**Limitations:** requires `insecure-registries` config on the HA host (not possible on HA OS); registry must be reachable over the network from the HA host.

---

### Option C — `docker save` / `docker load` via SSH

Best for: one-off tests when no registry is available; works on any HA install type with SSH.

The HA supervisor names local addon images as `local/{slug}:latest`. If an image with that tag is already loaded in Docker on the HA host, the supervisor uses it without rebuilding.

```bash
# Build with the exact tag the supervisor expects
docker build -t local/dockhand:latest ./dockhand

# Stream directly to the HA host over SSH
docker save local/dockhand:latest | gzip | ssh root@<ha-host> 'gunzip | docker load'
```

Then start the addon without triggering a rebuild:

```bash
# On HA host
ha apps start local_dockhand
```

> If the addon has never been installed on the HA host, install it once normally first (so the supervisor registers it), then replace the image via `docker save/load` for subsequent iterations.

**Limitations:** full image transfer over SSH each iteration (can be slow for large images); requires SSH access.

---

## Reverting to GHCR Image

Remove the `image` field from `dockhand/config.yaml` if you added it for Option B, or reinstall the addon from the store. The supervisor will pull the published GHCR image on next install/update.
