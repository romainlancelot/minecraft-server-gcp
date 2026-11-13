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

# Install or remove Geyser & Floodgate plugins for Bedrock support
mkdir -p "$MNT_DIR/plugins"
rm -f "$MNT_DIR/plugins/"*Geyser*.jar "$MNT_DIR/plugins/"*geyser*.jar "$MNT_DIR/plugins/"*floodgate*.jar "$MNT_DIR/plugins/"*Floodgate*.jar
if [ "${enable_bedrock}" = "true" ]; then
  curl -fsSL -o "$MNT_DIR/plugins/Geyser-Spigot.jar" "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
  curl -fsSL -o "$MNT_DIR/plugins/floodgate-spigot.jar" "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"
  if [ -f "$MNT_DIR/plugins/Geyser-Spigot/config.yml" ]; then
    sed -i 's/auth-type: online/auth-type: floodgate/g' "$MNT_DIR/plugins/Geyser-Spigot/config.yml"
  fi
fi

# Run Minecraft Server
docker run -d \
  --name mc \
  --restart always \
  -p 25565:25565 \
  -p ${voice_chat_port}:${voice_chat_port}/udp \
%{ if enable_bedrock ~}
  -p ${bedrock_port}:${bedrock_port}/tcp \
  -p ${bedrock_port}:${bedrock_port}/udp \
%{ endif ~}
  -v $MNT_DIR:/data \
  -e EULA=TRUE \
  -e VERSION=${minecraft_version} \
  -e MEMORY=${minecraft_memory} \
  -e TYPE=${minecraft_type} \
  -e DIFFICULTY=${minecraft_difficulty} \
  -e MOTD="${minecraft_motd}" \
  -e MAX_PLAYERS=${minecraft_max_players} \
  -e ENABLE_RCON=${minecraft_enable_rcon} \
  -e ENFORCE_SECURE_PROFILE=${enforce_secure_profile} \
  -e OPS="${minecraft_ops}" \
  -e ICON="${minecraft_icon}" \
  -e MODRINTH_PROJECTS="${modrinth_projects}" \
  ${minecraft_image}

# On first boot, wait for Geyser to generate config.yml and set auth-type to floodgate
if [ "${enable_bedrock}" = "true" ]; then
  for i in $(seq 1 30); do
    if [ -f "$MNT_DIR/plugins/Geyser-Spigot/config.yml" ]; then
      if grep -q "auth-type: online" "$MNT_DIR/plugins/Geyser-Spigot/config.yml"; then
        sed -i 's/auth-type: online/auth-type: floodgate/g' "$MNT_DIR/plugins/Geyser-Spigot/config.yml"
        docker restart mc
      fi
      break
    fi
    sleep 2
  done
fi
