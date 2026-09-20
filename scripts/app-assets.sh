#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${APP_PATH:?}"
APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"

if [[ -f "${APP_PATH}/package.json" ]]; then
  echo "[${APP_CONTAINER_NAME}] Building assets with bun..."
  # Skip prepare/postinstall: skills-npm, husky, and similar hooks fail in containers.
  (cd "${APP_PATH}" && bun install --ignore-scripts && bun run build)
fi
