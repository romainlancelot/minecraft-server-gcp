resource "google_compute_disk" "minecraft_data" {
  name = "minecraft-data"
  type = "pd-standard"
  zone = var.zone
  size = var.minecraft_disk_size

  lifecycle {
    prevent_destroy = true
  }
}
