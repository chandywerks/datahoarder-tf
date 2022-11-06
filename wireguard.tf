resource "docker_network" "vpn" {
  name   = "vpn"
  driver = "bridge"
}

data "docker_registry_image" "wireguard" {
  name = "linuxserver/wireguard"
}

// TODO provider bug causes docker image update to trigger every run
// https://github.com/kreuzwerker/terraform-provider-docker/issues/426
resource "docker_image" "wireguard" {
  name = data.docker_registry_image.wireguard.name
  pull_triggers = [data.docker_registry_image.wireguard.sha256_digest]
}

resource "docker_container" "vpn_gateway" {
  image   = docker_image.wireguard.name
  name    = "wireguard"
  restart = "unless-stopped"

  upload {
    file    = "/config/wg0.conf"
    content = templatefile("${path.module}/wireguard.tftpl", {
      private_key      = wireguard_asymmetric_key.peer.private_key
      peer_public_key  = local.mullvad_peer_relay.public_key
      peer_endpoint_ip = local.mullvad_peer_relay.ipv4_address
      ipv4_address     = mullvad_wireguard.peer.ipv4_address
      ipv6_address     = mullvad_wireguard.peer.ipv6_address
      dns              = "8.8.8.8"
    })
  }

  volumes {
    host_path      = "/lib/modules"
    container_path = "/lib/modules"
    read_only      = true
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
