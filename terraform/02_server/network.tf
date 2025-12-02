resource "google_compute_network" "vpc_network" {
  name                    = "minecraft-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft-server"]
}

resource "google_compute_firewall" "allow-minecraft" {
  name    = "allow-minecraft"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["25565"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft-server"]
}
