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
