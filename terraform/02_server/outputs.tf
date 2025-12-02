output "minecraft_server_ip" {
  value       = google_compute_instance.minecraft_server.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the Minecraft server"
}
