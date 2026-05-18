# Stage 1 — extract Dockhand artifacts
FROM fnsys/dockhand:v1.0.29 AS dockhand

# Stage 2 — HA Debian base (glibc, s6-overlay, bashio)
FROM ghcr.io/home-assistant/base-debian:trixie-2026.04.0

# Install nginx, docker-cli, and Node.js 24 (NodeSource)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gnupg \
        nginx \
        docker.io \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create dockhand user (matching Dockhand's uid/gid 1001)
RUN groupadd -g 1001 dockhand \
    && useradd -u 1001 -g dockhand -m -d /home/dockhand dockhand

# Copy Dockhand application from Stage 1
COPY --from=dockhand --chown=dockhand:dockhand /app /app
COPY --from=dockhand --chown=dockhand:dockhand /home/dockhand /home/dockhand

# Copy rootfs (nginx config, s6 services, cont-init scripts)
COPY rootfs /
RUN chmod +x /etc/cont-init.d/*.sh \
    && chmod +x /etc/services.d/*/run /etc/services.d/*/finish

ENV DATA_DIR=/data \
    PORT=3000 \
    HOST=127.0.0.1 \
    NODE_ENV=production

LABEL \
    org.opencontainers.image.title="Home Assistant App: Dockhand" \
    org.opencontainers.image.description="Modern Docker management UI for Home Assistant." \
    org.opencontainers.image.source="https://github.com/alexschwantes/hassio-dockhand" \
    org.opencontainers.image.licenses="Apache License 2.0"\