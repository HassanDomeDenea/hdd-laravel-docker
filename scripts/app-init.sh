#!/usr/bin/env bash
set -euo pipefail

APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"
APP_PATH="${APP_PATH:?}"
APP_REPO="${APP_REPO:-}"
APP_BRANCH="${APP_BRANCH:-main}"
APP_TOKEN="${APP_TOKEN:-}"
APP_ENV_PATH="${APP_ENV_PATH:-$APP_PATH/.env}"

mkdir -p "${APP_PATH}"

if [[ ! -d "${APP_PATH}/.git" ]]; then
  if [[ -z "${APP_REPO}" ]]; then
    echo "[${APP_CONTAINER_NAME}] APP_REPO is empty; skipping clone."
  else
    echo "[${APP_CONTAINER_NAME}] Cloning repository..."
    repo_url="${APP_REPO}"
    # Handle HTTPS URLs with token authentication
    if [[ -n "${APP_TOKEN}" && "${APP_REPO}" == https://* ]]; then
      repo_url="https://${APP_TOKEN}@${APP_REPO#https://}"
    fi

    # SSH URLs (git@...) use SSH agent forwarding automatically
    TEMP_CLONE_DIR="/tmp/app_clone_$$"
    git clone --branch "${APP_BRANCH}" "${repo_url}" "${TEMP_CLONE_DIR}"
    # Copy contents from temp directory to APP_PATH, preserving existing files
    cp -r "${TEMP_CLONE_DIR}"/.git "${APP_PATH}/"
    cp -r "${TEMP_CLONE_DIR}"/* "${APP_PATH}/"
    cp -r "${TEMP_CLONE_DIR}"/.[!.]* "${APP_PATH}/" 2>/dev/null || true
    rm -rf "${TEMP_CLONE_DIR}"
  fi
fi

if [[ -f "${APP_ENV_PATH}" ]]; then
  cp -f "${APP_ENV_PATH}" "${APP_PATH}/.env"
elif [[ -f "${APP_PATH}/.env.example" ]]; then
  cp -f "${APP_PATH}/.env.example" "${APP_PATH}/.env"
fi

if [[ -d "${APP_PATH}" ]]; then
  /opt/scripts/app-post-merge.sh "init"
fi

if [[ "${APP_GIT_PULL_ON_START}" == "1" ]]; then
  /opt/scripts/app-update.sh
fi
