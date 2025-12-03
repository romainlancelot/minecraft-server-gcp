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
