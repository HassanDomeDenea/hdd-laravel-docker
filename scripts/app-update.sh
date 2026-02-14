#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${APP_PATH:?}"
APP_CONTAINER_NAME="${APP_CONTAINER_NAME:-app}"
APP_REPO="${APP_REPO:-}"
APP_BRANCH="${APP_BRANCH:-main}"
APP_TOKEN="${APP_TOKEN:-}"

if [[ ! -d "${APP_PATH}/.git" ]]; then
  echo "[${APP_CONTAINER_NAME}] No git repo found; skipping update."
  exit 0
fi

repo_url="${APP_REPO}"
# Handle HTTPS URLs with token authentication
if [[ -n "${APP_TOKEN}" && "${APP_REPO}" == https://* ]]; then
  repo_url="https://${APP_TOKEN}@${APP_REPO#https://}"
fi
# SSH URLs (git@...) use SSH agent forwarding automatically

cd "${APP_PATH}"
git remote set-url origin "${repo_url}" || true
before_rev="$(git rev-parse HEAD)"
git fetch --all --prune
git checkout -B "${APP_BRANCH}" "origin/${APP_BRANCH}"
git reset --hard "origin/${APP_BRANCH}"
after_rev="$(git rev-parse HEAD)"

if [[ "${before_rev}" != "${after_rev}" ]]; then
  echo "[${APP_CONTAINER_NAME}] Changes detected; running post-merge tasks."
  /opt/scripts/app-post-merge.sh "update"
else
  echo "[${APP_CONTAINER_NAME}] No changes detected."
fi
