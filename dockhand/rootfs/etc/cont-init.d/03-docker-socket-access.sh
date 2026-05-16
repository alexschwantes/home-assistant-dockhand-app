#!/usr/bin/with-contenv bashio
# ==============================================================================
# Ensure dockhand user can access the mounted Docker socket.
# The socket GID can vary by host, so map group membership dynamically.
# ==============================================================================

set -e

SOCKET_PATH="/var/run/docker.sock"
APP_USER="dockhand"
DYNAMIC_GROUP="dockersock"

if [[ ! -S "${SOCKET_PATH}" ]]; then
    bashio::log.warning "Docker socket not found at ${SOCKET_PATH}; skipping permission mapping"
    exit 0
fi

SOCKET_GID="$(stat -c '%g' "${SOCKET_PATH}")"
if [[ -z "${SOCKET_GID}" ]]; then
    bashio::log.warning "Unable to read Docker socket GID; skipping permission mapping"
    exit 0
fi

GROUP_NAME="$(getent group "${SOCKET_GID}" | cut -d: -f1 || true)"
if [[ -z "${GROUP_NAME}" ]]; then
    GROUP_NAME="${DYNAMIC_GROUP}"

    if getent group "${GROUP_NAME}" >/dev/null; then
        # Reuse existing group name by recreating it with the socket's GID.
        groupdel "${GROUP_NAME}" || true
    fi

    groupadd -g "${SOCKET_GID}" "${GROUP_NAME}"
    bashio::log.info "Created group ${GROUP_NAME} with gid ${SOCKET_GID} for Docker socket access"
fi

if id -nG "${APP_USER}" | tr ' ' '\n' | grep -Fxq "${GROUP_NAME}"; then
    bashio::log.info "${APP_USER} already has Docker socket group access (${GROUP_NAME})"
else
    usermod -aG "${GROUP_NAME}" "${APP_USER}"
    bashio::log.info "Granted ${APP_USER} access to Docker socket via group ${GROUP_NAME}"
fi
