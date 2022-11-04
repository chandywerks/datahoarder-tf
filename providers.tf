terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.0"
    }

    mullvad = {
      source = "OJFord/mullvad"
      version = "~> 0.2.2"
    }

    wireguard = {
      source = "OJFord/wireguard"
      version = "~> 0.2.1"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

