#!/usr/bin/env bash
set -euo pipefail

APP_NAME="${APP_NAME:-app}"
APP_PATH="${APP_PATH:-/var/www/app}"
APP_PORT="${APP_PORT:-8000}"
APP_REPO="${APP_REPO:-}"
APP_BRANCH="${APP_BRANCH:-main}"
APP_TOKEN="${APP_TOKEN:-}"
APP_ENV_PATH="${APP_ENV_PATH:-$APP_PATH/.env}"

APP_RUN_MIGRATIONS="${APP_RUN_MIGRATIONS:-1}"
APP_RUN_OPTIMIZE="${APP_RUN_OPTIMIZE:-1}"
APP_RUN_STORAGE_LINK="${APP_RUN_STORAGE_LINK:-1}"
APP_RUN_QUEUE="${APP_RUN_QUEUE:-1}"
APP_RUN_SCHEDULE="${APP_RUN_SCHEDULE:-1}"
APP_RUN_REVERB="${APP_RUN_REVERB:-0}"
APP_RUN_OCTANE="${APP_RUN_OCTANE:-0}"
APP_REVERB_PORT="${APP_REVERB_PORT:-8080}"
APP_BUILD_ASSETS="${APP_BUILD_ASSETS:-0}"

APP_GIT_PULL_ENABLED="${APP_GIT_PULL_ENABLED:-1}"
APP_GIT_PULL_ON_START="${APP_GIT_PULL_ON_START:-1}"
APP_GIT_PULL_SCHEDULE="${APP_GIT_PULL_SCHEDULE:-0 2 * * *}"

export APP_NAME APP_PATH APP_PORT APP_REPO APP_BRANCH APP_TOKEN APP_ENV_PATH
export APP_RUN_MIGRATIONS APP_RUN_OPTIMIZE APP_RUN_STORAGE_LINK
export APP_RUN_QUEUE APP_RUN_SCHEDULE APP_RUN_REVERB APP_RUN_OCTANE APP_REVERB_PORT
export APP_BUILD_ASSETS APP_GIT_PULL_ENABLED APP_GIT_PULL_ON_START APP_GIT_PULL_SCHEDULE

# Fix SSH key permissions (Windows mounts as 0777, SSH requires 600)
if [[ -f /root/.ssh/id_ed25519 ]]; then
  cp /root/.ssh/id_ed25519 /tmp/ssh_key
  chmod 600 /tmp/ssh_key
  echo -e "Host *\n  IdentityFile /tmp/ssh_key\n  StrictHostKeyChecking no" > /root/.ssh/config
  chmod 600 /root/.ssh/config
fi

/opt/scripts/app-init.sh

if [[ "${APP_GIT_PULL_ENABLED}" == "1" ]]; then
  /opt/scripts/app-cron.sh
fi

/opt/scripts/app-processes.sh
