resource "yandex_compute_instance_group" "ig-1" {
  name               = "ig-1"
  service_account_id = "aje1h3hj21lk2ibpq5ud"

  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = 20
      }
    }

    network_interface {
      network_id = yandex_vpc_network.my-vpc.id
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }

    metadata = {
      user-data = "${file("cloud-init.yaml")}"
    }
  }

  scale_policy {
    auto_scale {
      initial_size           = 3
      measurement_duration   = 60
      cpu_utilization_target = 75
      min_zone_size          = 3
      max_size               = 3
      warmup_duration        = 60
      stabilization_duration = 120
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  #load_balancer {      ----------- network_load_balancer ------------
  #  target_group_name        = "target-group"
  #  target_group_description = "load balancer target group"
  # }

  application_load_balancer {
    target_group_name        = "target-group"
    target_group_description = "load balancer target group"
  }
}

resource "yandex_alb_backend_group" "bg-1" {
  name = "bg-1"
  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name   = "backend"
    weight = 1
    port   = 80

    target_group_ids = ["${yandex_compute_instance_group.ig-1.application_load_balancer.0.target_group_id}"]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "hr-1" {
  name = "hr-1"
  labels = {
    tf-label    = "lv-1"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "vh-1" {
  name           = "vh-1"
  http_router_id = yandex_alb_http_router.hr-1.id
  route {
    name = "r-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg-1.id
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "test-balancer" {
  name = "my-load-balancer"

  network_id = yandex_vpc_network.my-vpc.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }
  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.hr-1.id
      }
    }
  }
}