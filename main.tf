resource "yandex_compute_instance" "vm-public" {
  name        = "vm-public"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-public-vm.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
  }

    metadata = {
      user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.ssh_key_vm_user}"
    }
}


resource "yandex_compute_instance" "vm-private" {
  name        = "vm-private"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-private-vm.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
  }

  metadata = {
      user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${var.ssh_key_vm_user}"
    }

  connection {
    type        = "ssh"
    user        = "marat"
    host        = yandex_compute_instance.vm-public.network_interface[0].nat_ip_address
    private_key = file("${var.private_key}")
  }

    provisioner "local-exec" {
    command = "scp -o \"StrictHostKeyChecking no\" -i ${var.private_key}  ${var.private_key} marat@${yandex_compute_instance.vm-public.network_interface[0].nat_ip_address}:~/.ssh/id_rsa"
  }
}

resource "yandex_compute_disk" "boot-private-vm" {
  name     = "boot-public-vm"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8a28k7fnc9u68s45g5"
}

resource "yandex_compute_disk" "boot-public-vm" {
  name     = "boot-private-vm"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd8a28k7fnc9u68s45g5"
}