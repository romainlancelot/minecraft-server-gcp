variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  default = "europe-west9"
  type    = string
}

variable "zone" {
  default = "europe-west9-b"
  type    = string
}

variable "minecraft_disk_size" {
  description = "Persistent disk size in GB"
  default     = 20
  type        = number
}

variable "machine_type" {
  description = "Machine type for the Minecraft server"
  default     = "e2-medium"
  type        = string
}

variable "minecraft_image" {
  description = "Docker image for Minecraft server"
  default     = "itzg/minecraft-server:java25"
  type        = string
}

variable "minecraft_version" {
  description = "Minecraft version (e.g., LATEST, 1.20.1)"
  default     = "LATEST"
  type        = string
}

variable "minecraft_memory" {
  description = "Java heap memory for Minecraft (e.g., 2G, 3072M)"
  default     = "2G"
  type        = string
}

variable "minecraft_type" {
  description = "Server type (VANILLA, SPIGOT, PAPER, etc.)"
  default     = "VANILLA"
  type        = string
}

variable "modrinth_projects" {
  description = "List of Modrinth projects to install (slugs or IDs, comma-separated)"
  default     = ""
  type        = string
}

variable "voice_chat_port" {
  description = "UDP port for Simple Voice Chat"
  default     = 24454
  type        = number
}

variable "minecraft_difficulty" {
  description = "Game difficulty"
  default     = "normal"
  type        = string
}

variable "minecraft_motd" {
  description = "Message of the Day"
  default     = "Minecraft Server on GCP"
  type        = string
}

variable "minecraft_max_players" {
  description = "Maximum number of players"
  default     = 10
  type        = number
}

variable "minecraft_enable_rcon" {
  description = "Enable RCON"
  default     = true
  type        = bool
}

variable "use_spot_instance" {
  description = "Use Spot VM (cheaper but can be stopped by GCP)"
  default     = false
  type        = bool
}

variable "enable_static_ip" {
  description = "Enable static IP address creation and usage"
  default     = true
  type        = bool
}

variable "enable_scheduler" {
  description = "Enable automatic start/stop scheduler"
  default     = false
  type        = bool
}

variable "scheduler_start_time" {
  description = "Cron schedule for starting the server (e.g., '0 8 * * *' for 8 AM)"
  default     = "0 8 * * *"
  type        = string
}

variable "scheduler_stop_time" {
  description = "Cron schedule for stopping the server (e.g., '0 23 * * *' for 10 PM)"
  default     = "0 23 * * *"
  type        = string
}

variable "scheduler_timezone" {
  description = "Timezone for the scheduler"
  default     = "Europe/Paris"
  type        = string
}

variable "minecraft_ops" {
  description = "List of players to grant Operator (OP) status (comma-separated usernames)"
  default     = ""
  type        = string
}

variable "minecraft_icon" {
  description = "URL to the server icon image (PNG, JPG, etc.)"
  default     = "https://www.gstatic.com/cgc/super_cloud.png"
  type        = string
}
