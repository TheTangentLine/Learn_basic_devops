#!/bin/bash

# Setup directories (Using -p ensures no error if they already exist)
mkdir -p dummy_folder backups

SOURCE="dummy_folder"
DEST="backups"
DATE=$(date +%F)
FILE="backup-$DATE.tar.gz"

# Create the archive directly into the destination
# -c: Create, -z: Gzip, -v: Verbose, -f: File
echo "Starting backup of $SOURCE..."
tar -czvf "$DEST/$FILE" "$SOURCE"

# Verify
if [ -f "$DEST/$FILE" ]; then
    echo "✅ Success: Backup saved to $DEST/$FILE"
else
    echo "❌ Error: Backup failed!"
    exit 1
fi