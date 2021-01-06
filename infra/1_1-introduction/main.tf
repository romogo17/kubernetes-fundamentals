variable "gcp_project" {
  type        = string
  description = "The id of Google Cloud project in which the infrastructure will be deployed"
}

provider "google" {
  project = var.gcp_project
  region  = "us-east1"
  zone    = "us-east1-b"
}

resource "google_compute_instance" "vm_instance" {
  name         = "kube-instance"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-8"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.vpc_subnetwork.self_link
    access_config {
    }
  }

  metadata = {
    ssh-keys = "kube-user:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name          = "kube-subnetwork-us-east1"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-east1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "vpc_firewall" {
  name    = "allow-icmp-ssh-rdp"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "kube-vpc"
  auto_create_subnetworks = false
}
