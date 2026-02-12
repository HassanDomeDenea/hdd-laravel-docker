# Laravel Multi-App Docker Stack (FrankenPHP)

This project provides a configurable Docker setup for up to four Laravel apps, plus optional MariaDB, Redis, and MinIO. Each app is cloned on first run, kept up to date via git pull on startup and on a daily schedule, and can run queues, schedules, Reverb, Octane, and optional asset builds.

## Quick Start

1. Copy the docker env template:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` and set each app repo, ports, and options.

3. Edit per-app Laravel env files in `env/app1.env`, `env/app2.env`, etc. They are copied into each repo on container start.

4. Start the stack (app1 runs by default):
   ```bash
   docker compose up -d --build
   ```

5. Enable optional services or extra apps with profiles:
   ```bash
   docker compose --profile mariadb --profile redis --profile minio up -d
   docker compose --profile app2 --profile app3 up -d
   ```

## App Lifecycle

On first run or when the repo is missing, the app is cloned from `APPx_REPO`. Every startup runs:
- `composer install`
- `php artisan storage:link` (optional)
- `php artisan migrate --force` (optional)
- `php artisan optimize` (optional)
- optional asset build with Bun

If git updates detect changes, the same post-merge steps run after pull.

## Scheduled Updates

Each app can auto-update on a schedule via cron inside the container.
- Enable with `APPx_GIT_PULL_ENABLED=1`
- Set time with `APPx_GIT_PULL_SCHEDULE` (cron format, default `0 2 * * *`)
- Startup pull with `APPx_GIT_PULL_ON_START=1`

## Optional Services

Enable any of these profiles in `docker compose`:
- `mariadb`
- `redis`
- `minio`

## Ports

Default ports:
- app1: 8081
- app2: 8082
- app3: 8083
- app4: 8084
- mariadb: 3306
- redis: 6379
- minio: 9000 (console 9001)

## Directory Layout

- `apps/app1` .. `apps/app4`: cloned repositories
- `env/app1.env` .. `env/app4.env`: Laravel `.env` files per app
- `data/app1/storage`, `data/app1/database`: persistent volumes per app
- `data/mariadb`, `data/redis`, `data/minio`: optional service data
- `scripts/`: entrypoint and lifecycle scripts

## Common Configuration Options

Docker `.env` highlights:
```
PHP_VERSION=latest
APP1_REPO=https://github.com/your-org/your-app1.git
APP1_TOKEN= # optional, for private repos
APP1_GIT_PULL_SCHEDULE=0 2 * * *
APP1_BUILD_ASSETS=1
APP1_RUN_REVERB=1
APP1_RUN_OCTANE=1
```

Per-app Laravel env (example in `env/app1.env`):
```
DB_CONNECTION=sqlite
DB_DATABASE=/var/www/app1/database/database.sqlite
DB_HOST=mariadb
REDIS_HOST=redis
```

## Notes

- Private repo tokens are used with HTTPS URLs. Example:
  `APP1_REPO=https://github.com/owner/repo.git` and `APP1_TOKEN=ghp_xxx`
- If you use SQLite, the database file is created automatically on init.
- You can turn any worker off per app by setting:
  `APPx_RUN_QUEUE=0`, `APPx_RUN_SCHEDULE=0`, `APPx_RUN_REVERB=0`

## SSH Key Setup for Private Repositories

If your private repository uses SSH instead of HTTPS, you'll need to generate and add SSH keys.

### Linux

1. Generate SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
   Press Enter to accept the default location (`~/.ssh/id_ed25519`).

2. Copy the public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. Add the key to your Git provider (GitHub, GitLab, etc.) in Settings → SSH Keys.

4. Mount the SSH key in `docker-compose.yml`:
   ```yaml
   volumes:
     - ~/.ssh:/root/.ssh:ro
   ```

### Windows

1. Generate SSH key (PowerShell or Git Bash):
   ```powershell
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```
   Press Enter to accept the default location (`C:\Users\YourUsername\.ssh\id_ed25519`).

2. Copy the public key:
   ```powershell
   type $home\.ssh\id_ed25519.pub
   ```

3. Add the key to your Git provider (GitHub, GitLab, etc.) in Settings → SSH Keys.

4. Mount the SSH key in `docker-compose.yml`:
   ```yaml
   volumes:
     - ~\.ssh:/root/.ssh:ro
   ```

**Note:** For SSH repositories, use the SSH URL format in your `.env` file:
```
APP1_REPO=git@github.com:owner/repo.git
```

## Usage Examples

Start only app1 with MariaDB:
```bash
docker compose --profile mariadb up -d --build
```

Start app1 + app2 + Redis + MinIO:
```bash
docker compose --profile app2 --profile redis --profile minio up -d --build
```

Tail logs for app1:
```bash
docker compose logs -f app1
```

## Next Ideas

- Add a nightly backup job for `data/` volumes.
- Add healthchecks and alerts based on HTTP and queue health.
