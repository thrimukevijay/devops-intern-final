variable "image_tag" {
  type        = string
  description = "Immutable GHCR image tag to deploy."
}

job "nginx-app" {
  datacenters = ["dc1"]
  type = "service"

  group "nginx" {
    count = 1

    network {
      port "http" { to = 8080 }
    }

    update {
      max_parallel = 1
      min_healthy_time = "10s"
      healthy_deadline = "2m"
      auto_revert = true
    }

    restart { attempts = 3; interval = "5m"; delay = "15s"; mode = "fail" }
    reschedule { attempts = 3; interval = "30m"; delay = "30s"; delay_function = "exponential"; max_delay = "5m" }

    service {
      name = "nginx-app"
      port = "http"
      check {
        type = "http"
        path = "/healthz"
        interval = "10s"
        timeout = "2s"
      }
    }

    task "nginx" {
      driver = "docker"
      config {
        image = "ghcr.io/REPLACE_WITH_GITHUB_OWNER/devops-intern-final:${var.image_tag}"
        ports = ["http"]
      }
      resources { cpu = 100; memory = 64 }
    }
  }
}
