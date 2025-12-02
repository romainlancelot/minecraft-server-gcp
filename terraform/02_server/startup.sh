#!/bin/bash

# Format and mount the persistent disk
MNT_DIR=/mnt/disks/minecraft
DEVICE_ID=google-minecraft-data

if [ ! -d $MNT_DIR ]; then
  mkdir -p $MNT_DIR
fi

# Check if device is formatted
if ! blkid /dev/disk/by-id/$DEVICE_ID; then
  mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/$DEVICE_ID
fi

mount -o discard,defaults /dev/disk/by-id/$DEVICE_ID $MNT_DIR
chmod a+w $MNT_DIR

# Run Minecraft Server
docker run -d \
  --name mc \
  --restart always \
  -p 25565:25565 \
  -v $MNT_DIR:/data \
  -e EULA=TRUE \
  -e MEMORY=3G \
  itzg/minecraft-server
