#!/bin/bash
set -euo pipefail

echo "==> Creating data directories..."
mkdir -p /app/data/tshock/logs
mkdir -p /app/data/tshock/crashes
mkdir -p /app/data/tshock/backups
mkdir -p /app/data/worlds
mkdir -p /app/data/plugins

# -----------------------------------------------------------------------
# First-run initialisation
# -----------------------------------------------------------------------
if [ ! -f /app/data/.initialized ]; then
    echo "==> First installation detected – configuring TShock..."

    # Generate a random 32-char hex REST API token.
    # Reading /proc/sys/kernel/random/uuid avoids the SIGPIPE issue that
    # occurs when using `tr ... | head` with set -euo pipefail.
    REST_TOKEN=$(cat /proc/sys/kernel/random/uuid | tr -d '-')

    # Write a minimal config.json that enables the REST API.
    # TShock merges this with its own defaults for every other field.
    cat > /app/data/tshock/config.json <<TSHOCKCONFIG
{
    "ServerPort": 7777,
    "MaxSlots": 16,
    "ServerPassword": "${TERRARIA_PASSWORD:-}",
    "RestApiEnabled": true,
    "RestApiPort": 7878,
    "ApplicationRestTokens": {
        "${REST_TOKEN}": {
            "UserGroupName": "superadmin",
            "CreatedBy": "cloudron-setup"
        }
    }
}
TSHOCKCONFIG

    # Persist the token so the admin can retrieve it later
    cat > /app/data/rest-api-credentials.txt <<CREDENTIALS
TShock REST API superadmin token
=================================
Token : ${REST_TOKEN}

Example usage:
  curl "https://<app-domain>/v2/server/status"
  curl "https://<app-domain>/v2/users/list?token=${REST_TOKEN}"

Keep this file safe – it grants full server control via the REST API.
CREDENTIALS

    echo "==> REST API token saved to /app/data/rest-api-credentials.txt"
    touch /app/data/.initialized
fi

# -----------------------------------------------------------------------
# Start TShock
# World is auto-created on first run if the .wld file does not exist.
# -autocreate is silently ignored when the world file already exists.
# -----------------------------------------------------------------------
WORLD_FILE="/app/data/worlds/World.wld"

# /root is read-only on Cloudron. Redirect HOME so that both .NET bundle
# extraction and Terraria user-data writes (favorites.json, etc.) go to /tmp.
export HOME=/tmp
export DOTNET_BUNDLE_EXTRACT_BASE_DIR=/tmp

# TShock writes ServerLog.txt to the working directory at static initialisation
# time, before -logpath is applied. /server is read-only on Cloudron, so move
# to a writable runtime directory first.
mkdir -p /run/tshock
cd /run/tshock

echo "==> Starting TShock Server..."

TSHOCK_ARGS=(
    -configpath        /app/data/tshock
    -logpath           /app/data/tshock/logs
    -crashdir          /app/data/tshock/crashes
    -worldselectpath   /app/data/worlds
    -additionalplugins /app/data/plugins
    -world             "${WORLD_FILE}"
    -autocreate        3
    -worldname         "World"
    -worldevil         random
)

exec /server/TShock.Server "${TSHOCK_ARGS[@]}"
