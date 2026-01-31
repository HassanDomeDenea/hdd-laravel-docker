#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${APP_PATH:?}"
APP_REPO="${APP_REPO:-}"
APP_BRANCH="${APP_BRANCH:-main}"
APP_TOKEN="${APP_TOKEN:-}"
APP_ENV_PATH="${APP_ENV_PATH:-$APP_PATH/.env}"

mkdir -p "${APP_PATH}"

if [[ ! -d "${APP_PATH}/.git" ]]; then
  if [[ -z "${APP_REPO}" ]]; then
    echo "[${APP_NAME}] APP_REPO is empty; skipping clone."
  else
    echo "[${APP_NAME}] Cloning repository..."
    repo_url="${APP_REPO}"
    if [[ -n "${APP_TOKEN}" && "${APP_REPO}" == https://* ]]; then
      repo_url="https://${APP_TOKEN}@${APP_REPO#https://}"
    fi
    git clone --branch "${APP_BRANCH}" "${repo_url}" "${APP_PATH}"
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
