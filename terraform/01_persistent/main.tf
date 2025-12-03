resource "google_compute_disk" "minecraft_data" {
  name = "minecraft-data"
  type = "pd-standard"
  zone = var.zone
  size = var.minecraft_disk_size

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_address" "static_ip" {
  count  = var.enable_static_ip ? 1 : 0
  name   = "minecraft-static-ip"
  region = var.region
}
