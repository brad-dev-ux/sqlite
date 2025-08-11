#!/usr/bin/env sh
set -e

DB_VOLUME_PATH="/data/database.db"
DB_IMAGE_PATH="/app/database.db"

# Provisionner la DB dans le volume au 1er démarrage
if [ ! -f "$DB_VOLUME_PATH" ]; then
  echo "No DB found in /data. Copying image DB to volume..."
  cp "$DB_IMAGE_PATH" "$DB_VOLUME_PATH"
else
  echo "DB already present in /data. Skipping initialization."
fi

# Lancer l'UI web pointant vers la DB du volume
exec python wsgi.py "$DB_VOLUME_PATH"
