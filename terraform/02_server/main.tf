data "google_compute_disk" "minecraft_data" {
  name = "minecraft-data"
  zone = var.zone
}

data "google_compute_address" "static_ip" {
  count  = var.enable_static_ip ? 1 : 0
  name   = "minecraft-static-ip"
  region = var.region
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

  scheduling {
    preemptible        = var.use_spot_instance
    automatic_restart  = var.use_spot_instance ? false : true
    provisioning_model = var.use_spot_instance ? "SPOT" : "STANDARD"
  }

  attached_disk {
    source      = data.google_compute_disk.minecraft_data.id
    device_name = "minecraft-data"
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = var.enable_static_ip ? data.google_compute_address.static_ip[0].address : null
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    minecraft_image       = var.minecraft_image
    minecraft_version     = var.minecraft_version
    minecraft_memory      = var.minecraft_memory
    minecraft_type        = var.minecraft_type
    minecraft_difficulty  = var.minecraft_difficulty
    minecraft_motd        = var.minecraft_motd
    minecraft_max_players = var.minecraft_max_players
    minecraft_enable_rcon = var.minecraft_enable_rcon
  })

  service_account {
    scopes = ["cloud-platform"]
  }
}
