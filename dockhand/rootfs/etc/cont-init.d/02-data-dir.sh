#!/usr/bin/with-contenv bashio
# ==============================================================================
# Ensure /data/db exists
# ==============================================================================
bashio::log.info "Initialising data directory..."

mkdir -p /data/db
