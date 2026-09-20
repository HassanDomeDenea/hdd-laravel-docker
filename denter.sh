#!/bin/bash
# Usage: denter <container-name>
# Example: denter lulua-live

if [ -z "$1" ]; then
  echo "Usage: denter <container-name>"
  exit 1
fi

CONTAINER="$1"
WORKDIR="/var/www/$CONTAINER"

docker exec -it -w "$WORKDIR" "$CONTAINER" bash