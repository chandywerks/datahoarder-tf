resource "docker_network" "vpn" {
  name   = "vpn"
  driver = "bridge"
}

resource "docker_image" "wireguard" {
  name = "lscr.io/linuxserver/wireguard:latest"
  // TODO pull triggers for auto update
}

resource "docker_container" "vpn_gateway" {
  image   = docker_image.wireguard.name
  name    = "wireguard"
  restart = "unless-stopped"

  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
  }

// TODO automatically generate wireguard config from managed mullvad resources
// https://www.linuxserver.io/blog/routing-docker-host-and-container-traffic-through-wireguard
  volumes {
    host_path      = "/media/datahoarder/wireguard"
    container_path = "/config"
  }

  ports {
    internal  = 51820
    external  = 51820
    protocol  = "udp"
  }

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/New_York" // TODO config file
  ]

  capabilities {
    add = ["SYS_MODULE", "NET_ADMIN"]
  }

  sysctls = {
    "net.ipv4.conf.all.src_valid_mark" = 1
    "net.ipv6.conf.all.disable_ipv6"   = 0
  }
}
