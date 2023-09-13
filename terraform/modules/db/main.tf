# Commented - Crutches for non-working tests

# terraform {
#   required_version = "~> 1.5.1"
#   required_providers {
#     yandex = {
#       source  = "yandex-cloud/yandex"
#       version = "~> 0.95.0"
#     }
#   }
# }

resource "yandex_compute_instance" "db" {
  count = var.app_count
  name  = "reddit-db-${var.environment}-${count.index}"
  labels = {
    tags = "reddit-db"
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.db_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    host        = self.network_interface.0.nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/deploy.sh"
    destination = "/tmp/deploy.sh"
  }
  provisioner "remote-exec" {
    inline = concat(["echo Provisioning"], [for command in ["chmod +x /tmp/deploy.sh", "/tmp/deploy.sh"]: command if var.provision])
  }
}
