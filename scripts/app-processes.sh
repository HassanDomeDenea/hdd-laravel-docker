#!/usr/bin/env bash
set -euo pipefail

APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"
APP_PATH="${APP_PATH:?}"
APP_PORT="${APP_PORT:-8000}"
APP_RUN_QUEUE="${APP_RUN_QUEUE:-1}"
APP_RUN_SCHEDULE="${APP_RUN_SCHEDULE:-1}"
APP_RUN_REVERB="${APP_RUN_REVERB:-0}"
APP_RUN_OCTANE="${APP_RUN_OCTANE:-0}"
APP_REVERB_PORT="${APP_REVERB_PORT:-8080}"

cd "${APP_PATH}"

if [[ ! -f "${APP_PATH}/artisan" ]]; then
  echo "[${APP_CONTAINER_NAME}] artisan not found; check APP_REPO and mounted path."
  exit 1
fi

if [[ "${APP_RUN_SCHEDULE}" == "1" ]]; then
  echo "[${APP_CONTAINER_NAME}] Starting schedule worker..."
  php artisan schedule:work &
fi

if [[ "${APP_RUN_QUEUE}" == "1" ]]; then
  echo "[${APP_CONTAINER_NAME}] Starting queue worker..."
  php artisan queue:work --sleep=3 --tries=3 &
fi

if [[ "${APP_RUN_REVERB}" == "1" ]]; then
  echo "[${APP_CONTAINER_NAME}] Starting Reverb server..."
  php artisan reverb:start --host=0.0.0.0 --port="${APP_REVERB_PORT}" &
fi

if [[ "${APP_RUN_OCTANE}" == "1" ]]; then
  exec php artisan octane:frankenphp --host=0.0.0.0 --port="${APP_PORT}"
else
  exec frankenphp php-server --root "${APP_PATH}/public" --listen "0.0.0.0:${APP_PORT}"
fi
