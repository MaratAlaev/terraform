resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-instanse.id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    ip_address         = "192.168.10.254"
    nat                = true
  }
}

resource "yandex_compute_disk" "boot-instanse" {
  name     = "boot-instanse"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd80mrhj8fl2oe87o4e1"
}