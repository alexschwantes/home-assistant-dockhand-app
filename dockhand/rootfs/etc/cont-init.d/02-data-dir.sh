#!/usr/bin/with-contenv bashio
# ==============================================================================
# Ensure /data/db exists and is owned by the dockhand user
# ==============================================================================
bashio::log.info "Initialising data directory..."

mkdir -p /data/db
chown -R dockhand:dockhand /data
