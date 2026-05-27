terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "worker_disk" {
  name           = "worker.qcow2"
  pool           = "default"
  source         = var.base_image_path
  format         = "qcow2"
}

resource "libvirt_volume" "db_disk" {
  name           = "db.qcow2"
  pool           = "default"
  source         = var.base_image_path
  format         = "qcow2"
}

data "template_file" "worker_cloud_init" {
  template = file("${path.module}/cloud-init/worker.yaml")
  vars = {
    ansible_public_key = var.ansible_public_key
  }
}

data "template_file" "db_cloud_init" {
  template = file("${path.module}/cloud-init/db.yaml")
  vars = {
    ansible_public_key = var.ansible_public_key
  }
}

resource "libvirt_cloudinit_disk" "worker_init" {
  name      = "worker-init.iso"
  pool      = "default"
  user_data = data.template_file.worker_cloud_init.rendered
}

resource "libvirt_cloudinit_disk" "db_init" {
  name      = "db-init.iso"
  pool      = "default"
  user_data = data.template_file.db_cloud_init.rendered
}

resource "libvirt_network" "lab_network" {
  name      = "lab-network"
  mode      = "nat"
  addresses = ["192.168.100.0/24"]
  dhcp {
    enabled = true
  }
}

resource "libvirt_domain" "worker" {
  name   = "worker"
  memory = "1024"
  vcpu   = 1
  machine = "pc"
  type = "qemu"

  cloudinit = libvirt_cloudinit_disk.worker_init.id

  network_interface {
    network_id     = libvirt_network.lab_network.id
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "db" {
  name   = "db"
  memory = "1024"
  vcpu   = 1
  machine = "pc"
  type = "qemu"

  cloudinit = libvirt_cloudinit_disk.db_init.id

  network_interface {
    network_id     = libvirt_network.lab_network.id
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "worker_ip" {
  value = libvirt_domain.worker.network_interface[0].addresses[0]
}

output "db_ip" {
  value = libvirt_domain.db.network_interface[0].addresses[0]
}