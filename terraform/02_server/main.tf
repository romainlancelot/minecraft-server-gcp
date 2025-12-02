data "google_compute_disk" "minecraft_data" {
  name = "minecraft-data"
  zone = var.zone
}

resource "google_compute_instance" "minecraft_server" {
  name         = "minecraft-server"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["minecraft-server"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  attached_disk {
    source      = data.google_compute_disk.minecraft_data.id
    device_name = "minecraft-data"
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      # Ephemeral public IP
    }
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  service_account {
    scopes = ["cloud-platform"]
  }
}
