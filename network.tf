resource "yandex_vpc_network" "my-vpc" {
  name = "my-vpc"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-vpc.id
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my-vpc.id
  route_table_id = yandex_vpc_route_table.private-route.id
}

resource "yandex_vpc_route_table" "private-route" {
  network_id = yandex_vpc_network.my-vpc.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface[0].ip_address
  }
}