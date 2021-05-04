variable "gcp_project" {
  type        = string
  description = "The id of Google Cloud project in which the infrastructure will be deployed"
}

provider "google" {
  project = var.gcp_project
  region  = "us-east1"
  zone    = "us-east1-b"
}

resource "google_compute_instance" "vm_instance_controlplane" {
  count        = 1
  name         = "kube-controlplane-node${count.index + 1}"
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
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "kube-user:${file("~/.ssh/id_rsa.pub")}"
  }

  labels = {
    lab             = "3_2"
    kubernetes_role = "controlplane"
  }
}

resource "google_compute_instance" "vm_instance_worker" {
  count        = 1
  name         = "kube-worker-node${count.index + 1}"
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
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "kube-user:${file("~/.ssh/id_rsa.pub")}"
  }

  labels = {
    lab             = "3_2"
    kubernetes_role = "worker"
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

output "controlplane_ip_addrs" {
  value = google_compute_instance.vm_instance_controlplane.*.network_interface.0.access_config.0.nat_ip
}
output "worker_ip_addrs" {
  value = google_compute_instance.vm_instance_worker.*.network_interface.0.access_config.0.nat_ip
}
