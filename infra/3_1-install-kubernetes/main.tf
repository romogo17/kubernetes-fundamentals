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
  name         = "kube-instance-singlenode"
  machine_type = "e2-standard-2"

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
  name    = "allow-all"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "all"
  }

}

resource "google_compute_network" "vpc_network" {
  name                    = "kube-vpc"
  auto_create_subnetworks = false
}


output "instance_self_link" {
  value = google_compute_instance.vm_instance.self_link
}

output "instance_external_ip_addr" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}

output "instance_ip_addr" {
  value = google_compute_instance.vm_instance.network_interface.0.network_ip
}


