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

resource "google_compute_firewall" "allow-voice-chat" {
  name    = "allow-voice-chat"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "udp"
    ports    = [var.voice_chat_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft-server"]
}

resource "google_compute_firewall" "allow-bedrock" {
  count   = var.enable_bedrock ? 1 : 0
  name    = "allow-bedrock"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = [var.bedrock_port]
  }

  allow {
    protocol = "udp"
    ports    = [var.bedrock_port]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["minecraft-server"]
}
