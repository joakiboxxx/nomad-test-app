job "joakibo_service" {
  datacenters = ["dc1"]
  type = "service"

  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    progress_deadline = "10m"
    auto_revert = false
    canary = 0
  }

  migrate {
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
    healthy_deadline = "5m"
  }

  group "backend_group" {
    count = 6

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "backend_task" {
      driver = "docker"

      config {
        image = "644898301346.dkr.ecr.eu-west-1.amazonaws.com/joakibo_backend:latest"
        port_map {
          backend = "8080"
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "backend" {}
        }
      }
      service {
        name = "backend"
        port = "backend"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }

  group "frontend_group" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "frontend_task" {
      driver = "docker"

      config {
        image = "644898301346.dkr.ecr.eu-west-1.amazonaws.com/joakibo_frontend:latest"
        port_map {
          frontend = "80"
        }
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 10
          port "frontend" {}
        }
      }

      service {
        name = "frontend"
        port = "frontend"

        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
