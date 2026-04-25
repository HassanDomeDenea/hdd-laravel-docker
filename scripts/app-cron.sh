#!/usr/bin/env bash
set -euo pipefail

APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"
APP_PATH="${APP_PATH:?}"
APP_REPO="${APP_REPO:-}"
APP_BRANCH="${APP_BRANCH:-main}"
APP_TOKEN="${APP_TOKEN:-}"
APP_GIT_PULL_SCHEDULE="${APP_GIT_PULL_SCHEDULE:-0 2 * * *}"

cron_file="/etc/cron.d/${APP_CONTAINER_NAME}-update"

cat > "${cron_file}" <<EOF
APP_CONTAINER_NAME=${APP_CONTAINER_NAME}
APP_PATH=${APP_PATH}
APP_REPO=${APP_REPO}
APP_BRANCH=${APP_BRANCH}
APP_TOKEN=${APP_TOKEN}

${APP_GIT_PULL_SCHEDULE} root /opt/scripts/app-update.sh --restart-container >> /proc/1/fd/1 2>&1
EOF

chmod 0644 "${cron_file}"

cron