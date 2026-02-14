#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${APP_PATH:?}"
APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"
APP_RUN_MIGRATIONS="${APP_RUN_MIGRATIONS:-1}"
APP_RUN_OPTIMIZE="${APP_RUN_OPTIMIZE:-1}"
APP_RUN_STORAGE_LINK="${APP_RUN_STORAGE_LINK:-1}"
APP_BUILD_ASSETS="${APP_BUILD_ASSETS:-0}"

if [[ ! -f "${APP_PATH}/composer.json" ]]; then
  echo "[${APP_CONTAINER_NAME}] composer.json not found; skipping init."
  exit 0
fi

if [[ -f "${APP_PATH}/.env" ]]; then
  db_connection="$(grep -E '^DB_CONNECTION=' "${APP_PATH}/.env" | tail -n1 | cut -d= -f2- || true)"
  db_database="$(grep -E '^DB_DATABASE=' "${APP_PATH}/.env" | tail -n1 | cut -d= -f2- || true)"
  if [[ "${db_connection}" == "sqlite" && -n "${db_database}" ]]; then
    mkdir -p "$(dirname "${db_database}")"
    touch "${db_database}"
  fi
fi



if [[ ! -d "${APP_PATH}/vendor" ]]; then
  echo "[${APP_CONTAINER_NAME}] Running composer install..."
  composer install --no-interaction --prefer-dist --optimize-autoloader --working-dir "${APP_PATH}"
else
  composer install --no-interaction --prefer-dist --optimize-autoloader --working-dir "${APP_PATH}"
fi



app_key="$(grep -E '^APP_KEY=' "${APP_PATH}/.env" | tail -n1 | cut -d= -f2- | tr -d '\r' | xargs || true)"
echo "${app_key}"
if [[ -z "${app_key}" ]]; then
  echo "[${APP_CONTAINER_NAME}] APP_KEY not found or empty; generating key..."
  php "${APP_PATH}/artisan" key:generate --force
  app_key="$(grep -E '^APP_KEY=' "${APP_PATH}/.env" | tail -n1 | cut -d= -f2-)"
else
  echo "[${APP_CONTAINER_NAME}] APP_KEY found: ${app_key}"
fi

if [[ "${APP_RUN_STORAGE_LINK}" == "1" ]]; then
  php "${APP_PATH}/artisan" storage:link || true
fi

if [[ "${APP_RUN_MIGRATIONS}" == "1" ]]; then
  php "${APP_PATH}/artisan" migrate --force || true
fi

if [[ "${APP_RUN_OPTIMIZE}" == "1" ]]; then
  php "${APP_PATH}/artisan" optimize || true
fi

if [[ "${APP_BUILD_ASSETS}" == "1" ]]; then
  /opt/scripts/app-assets.sh
fi

# Run per-app custom hook if it exists
HOOK_SCRIPT="/opt/scripts/hooks/${APP_CONTAINER_NAME}.sh"
if [[ -f "${HOOK_SCRIPT}" ]]; then
  echo "[${APP_CONTAINER_NAME}] Running custom hook: ${HOOK_SCRIPT}"
  bash "${HOOK_SCRIPT}"
fi
