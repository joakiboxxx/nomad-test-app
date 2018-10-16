job "test-service" {
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

  group "backend-group" {
    count = 3

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "backend-task" {
      driver = "docker"

      config {
        image = "joakiboxxx/nomad-test-app-backend:v20"
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

  group "frontend-group" {
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

    task "frontend-task" {
      driver = "docker"

      config {
        image = "joakiboxxx/nomad-test-app-frontend:v23"
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