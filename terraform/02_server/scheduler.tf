resource "google_compute_resource_policy" "start_stop" {
  count       = var.enable_scheduler ? 1 : 0
  name        = "minecraft-start-stop-schedule"
  region      = var.region
  description = "Start and stop the Minecraft server automatically"

  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.scheduler_start_time
    }
    vm_stop_schedule {
      schedule = var.scheduler_stop_time
    }
    time_zone = var.scheduler_timezone
  }
}
