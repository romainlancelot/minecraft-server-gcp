output "minecraft_public_ip" {
  description = "The static public IP address of the Minecraft server"
  value       = var.enable_static_ip ? google_compute_address.static_ip[0].address : null
}
