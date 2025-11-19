#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"

# Configure Apache to listen on the Render-provided port.
if grep -qE '^Listen ' /etc/apache2/ports.conf; then
  sed -ri "s/^Listen .*/Listen ${PORT}/" /etc/apache2/ports.conf
else
  echo "Listen ${PORT}" >> /etc/apache2/ports.conf
fi

# Update the virtual host to use the same port.
if [ -f /etc/apache2/sites-available/000-default.conf ]; then
  sed -ri "s/<VirtualHost \*:[0-9]+>/<VirtualHost *:${PORT}>/" /etc/apache2/sites-available/000-default.conf
fi

exec apache2-foreground "$@"

