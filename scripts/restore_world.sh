#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="minecraft-server"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
ZONE=$(gcloud config get-value compute/zone 2>/dev/null)

# Fallback defaults if not set in gcloud config
if [ -z "$ZONE" ]; then
    ZONE="europe-west9-b"
fi

if [ -z "$PROJECT_ID" ]; then
    echo "Error: No project ID found in gcloud config."
    echo "Please run 'gcloud config set project YOUR_PROJECT_ID' or edit this script."
    exit 1
fi

BACKUP_FILE="$1"

# If no backup file was passed as argument, look for available backup archives
if [ -z "$BACKUP_FILE" ]; then
    echo "No backup file specified. Searching for backups in current directory and scripts/..."
    BACKUPS=($(ls -t ./minecraft-backup-*.tar.gz ./scripts/minecraft-backup-*.tar.gz 2>/dev/null || true))
    
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        echo "Error: No backup archive found automatically."
        echo "Usage: $0 <path_to_backup.tar.gz>"
        exit 1
    fi

    echo "Available backups (sorted by newest):"
    for i in "${!BACKUPS[@]}"; do
        echo "  [$((i+1))] ${BACKUPS[$i]}"
    done

    read -p "Select a backup to restore [1-${#BACKUPS[@]}]: " CHOICE
    if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt "${#BACKUPS[@]}" ]; then
        echo "Invalid choice. Aborting."
        exit 1
    fi
    BACKUP_FILE="${BACKUPS[$((CHOICE-1))]}"
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: File '$BACKUP_FILE' does not exist."
    exit 1
fi

ARCHIVE_BASENAME=$(basename "$BACKUP_FILE")
REMOTE_TMP="/tmp/$ARCHIVE_BASENAME"

echo "=== Minecraft World Restore ==="
echo "Project: $PROJECT_ID"
echo "Zone:    $ZONE"
echo "Server:  $INSTANCE_NAME"
echo "Backup:  $BACKUP_FILE"
echo "==============================="
echo "WARNING: Restoring will overwrite existing data in /mnt/disks/minecraft."
read -p "Are you sure you want to proceed? [y/N] " CONFIRM

if ! [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 0
fi

echo "Uploading backup archive to server..."
gcloud compute scp --project="$PROJECT_ID" --zone="$ZONE" "$BACKUP_FILE" "$INSTANCE_NAME:$REMOTE_TMP"

echo "Stopping Minecraft server container if running..."
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="if sudo docker ps -q -f name=mc | grep -q .; then sudo docker stop mc; fi"

echo "Wiping existing files on persistent disk (excluding lost+found)..."
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="sudo find /mnt/disks/minecraft -mindepth 1 -maxdepth 1 ! -name 'lost+found' -exec rm -rf {} +"

echo "Extracting backup archive into /mnt/disks/minecraft..."
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="sudo tar -xzf $REMOTE_TMP -C /mnt/disks/minecraft"

echo "Setting permissions..."
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="sudo chmod -R a+rwX /mnt/disks/minecraft"

echo "Cleaning up remote archive..."
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="sudo rm -f $REMOTE_TMP"

echo "Starting Minecraft server container..."
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="sudo docker start mc"

echo "Waiting for server to start up..."
sleep 5

echo "Recent container logs:"
gcloud compute ssh "$INSTANCE_NAME" --project="$PROJECT_ID" --zone="$ZONE" \
    --command="sudo docker logs --tail 25 mc"

echo ""
echo "✅ World restored successfully from $BACKUP_FILE!"
