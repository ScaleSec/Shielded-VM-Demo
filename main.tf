locals {
  name = "${var.project_id}-shielded-demo"
}

provider "google-beta" {
  region  = var.region
  project = var.project_id
}

provider "google-beta" {
  alias   = "stackdriver"
  region  = var.region
  project = var.stackdriver_project
}

resource "google_compute_network" "shielded_vm_network" {
  provider                = google-beta
  name                    = "${local.name}-network"
  description             = "Network used for the Shielded VM demo"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "shielded_vm_subnetwork" {
  provider         = google-beta
  name             = "${local.name}-subnetwork"
  ip_cidr_range    = var.subnet_cidr_range
  region           = var.region
  network          = google_compute_network.shielded_vm_network.self_link
  enable_flow_logs = true
}

resource "google_compute_instance" "shielded_vm_instance" {
  provider     = google-beta
  name         = local.name
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.shielded_vm_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.shielded_vm_subnetwork.self_link

    access_config {
      // Ephemeral IP
    }
  }
  metadata_startup_script = "apt-get update"
  
  shielded_instance_config {
    enable_secure_boot          = var.enable_secure_boot
    enable_vtpm                 = var.enable_vtpm
    enable_integrity_monitoring = var.enable_integrity_monitoring
  }
}

resource "google_compute_firewall" "shielded_vm" {
  provider = google-beta
  name     = "${local.name}-firewall"
  network  = "${google_compute_network.shielded_vm_network.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.ssh_cidr_range]
}

resource "google_monitoring_alert_policy" "shielded_vm_alert_policy" {
  provider     = google-beta
  project      = var.stackdriver_project
  display_name = "Shielded_VM_Integrity_Fail"
  combiner     = "OR"
  conditions {
    display_name = "Late Boot Validation for failed"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/integrity/late_boot_validation_status\" AND resource.type=\"gce_instance\" AND metric.labels.status=\"failed\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        per_series_aligner = "ALIGN_SUM"
        alignment_period   = "60s"
        group_by_fields    = ["metric.labels.status"]
      }
    }
  }
  conditions {
    display_name = "Early Boot Validation for failed"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/integrity/early_boot_validation_status\" AND resource.type=\"gce_instance\" AND metric.labels.status=\"failed\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        per_series_aligner = "ALIGN_SUM"
        alignment_period   = "60s"
        group_by_fields    = ["metric.labels.status"]
      }
    }
  }
  notification_channels = [
    google_monitoring_notification_channel.shielded_vm_fail_email.name
  ]
}

resource "google_monitoring_notification_channel" "shielded_vm_fail_email" {
  provider     = google-beta
  project      = var.stackdriver_project
  display_name = "Shielded VM Failure Notification Channel"
  type         = "email"
  labels = {
    email_address = var.notification_email_address
  }
}