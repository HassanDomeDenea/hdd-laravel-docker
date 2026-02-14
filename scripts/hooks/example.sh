#!/usr/bin/env bash
# Example per-app custom hook script.
# Copy this file and rename it to match your APP_CONTAINER_NAME (e.g., app1.sh).
# It runs after composer install, migrations, optimize, and asset build.
#
# Available environment variables:
#   APP_CONTAINER_NAME, APP_PATH, APP_PORT, and all other APP_* vars
#
# Examples:
#   php "${APP_PATH}/artisan" db:seed --force
#   php "${APP_PATH}/artisan" scout:sync-index-settings
#   php "${APP_PATH}/artisan" horizon:publish
