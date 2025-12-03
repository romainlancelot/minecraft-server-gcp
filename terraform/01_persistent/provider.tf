terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }
  }

  backend "gcs" {
    bucket = "tf-bucket-state"
    prefix = "terraform/state/minecraft/persistent"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}
