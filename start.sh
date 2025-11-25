#!/bin/sh
set -e

# Create superuser if env vars are set
if [ -n "$PB_ADMIN_EMAIL" ] && [ -n "$PB_ADMIN_PASSWORD" ]; then
    echo "Setting up superuser..."
    ./server superuser upsert "$PB_ADMIN_EMAIL" "$PB_ADMIN_PASSWORD" || true
fi

# Start the server
exec ./server serve --http=0.0.0.0:${PORT:-8080}
