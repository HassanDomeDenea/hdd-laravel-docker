#!/usr/bin/env bash
set -euo pipefail

APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"
APP_GIT_PULL_SCHEDULE="${APP_GIT_PULL_SCHEDULE:-0 2 * * *}"

cron_file="/etc/cron.d/${APP_CONTAINER_NAME}-update"
echo "${APP_GIT_PULL_SCHEDULE} root /opt/scripts/app-update.sh >> /proc/1/fd/1 2>&1" > "${cron_file}"
chmod 0644 "${cron_file}"

cron
