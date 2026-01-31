#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${APP_PATH:?}"
APP_NAME="${APP_NAME:-app}"

if ! command -v bun >/dev/null 2>&1; then
  echo "[${APP_NAME}] Installing bun..."
  curl -fsSL https://bun.sh/install | bash
  export PATH="${HOME}/.bun/bin:${PATH}"
fi

if [[ -f "${APP_PATH}/package.json" ]]; then
  echo "[${APP_NAME}] Building assets with bun..."
  (cd "${APP_PATH}" && bun install && bun run build)
fi
