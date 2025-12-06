#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="minecraft-server"
# Try to get values from gcloud config
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

BACKUP_NAME="minecraft-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
REMOTE_TMP="/tmp/$BACKUP_NAME"

echo "=== Minecraft World Backup ==="
echo "Project: $PROJECT_ID"
echo "Zone:    $ZONE"
echo "Server:  $INSTANCE_NAME"
echo "Output:  $BACKUP_NAME"
echo "=============================="

read -p "Do you want to stop the server during backup to ensure data consistency? (Recommended) [y/N] " STOP_SERVER

if [[ "$STOP_SERVER" =~ ^[Yy]$ ]]; then
    echo "Stopping Minecraft server..."
    gcloud compute ssh $INSTANCE_NAME --project="$PROJECT_ID" --zone="$ZONE" --command="sudo docker stop mc"
else
    echo "Warning: Backing up while server is running. Data might be inconsistent."
    echo "Forcing save-all..."
    # Attempt to save if container is running
    gcloud compute ssh $INSTANCE_NAME --project="$PROJECT_ID" --zone="$ZONE" --command="if sudo docker ps | grep -q mc; then sudo docker exec mc rcon-cli save-all flush; fi"
fi

echo "Creating archive on remote server..."
# The data is in /mnt/disks/minecraft.
gcloud compute ssh $INSTANCE_NAME --project="$PROJECT_ID" --zone="$ZONE" --command="sudo tar -czf $REMOTE_TMP -C /mnt/disks/minecraft ."

echo "Downloading archive..."
gcloud compute scp --project="$PROJECT_ID" --zone="$ZONE" $INSTANCE_NAME:$REMOTE_TMP ./$BACKUP_NAME

echo "Cleaning up remote file..."
gcloud compute ssh $INSTANCE_NAME --project="$PROJECT_ID" --zone="$ZONE" --command="sudo rm $REMOTE_TMP"

if [[ "$STOP_SERVER" =~ ^[Yy]$ ]]; then
    echo "Restarting Minecraft server..."
    gcloud compute ssh $INSTANCE_NAME --project="$PROJECT_ID" --zone="$ZONE" --command="sudo docker start mc"
fi

echo "✅ Backup downloaded successfully: $BACKUP_NAME"
