resource "kubernetes_service" "vpn_gateway" {
  metadata {
    name = "vpn-gateway"
  }

  spec {
    port {
      port        = 51820
      target_port = 51820
      protocol    = "UDP"
    }

    type = "LoadBalancer"

    selector = {
      name = "wireguard"
    }
  }
}

resource "kubernetes_config_map" "wireguard" {
  metadata {
    name = "wireguard-conf"
  }

  data = {
    "wg0.conf" = templatefile("${path.module}/wireguard.tftpl", {
      private_key          = wireguard_asymmetric_key.peer.private_key
      endpoint_public_key  = local.mullvad_peer_relay.public_key
      endpoint_address     = local.mullvad_peer_relay.ipv4_address
      tunnel_address       = mullvad_wireguard.peer.ipv4_address
      dns                  = "8.8.8.8"
    })
  }
}

resource "kubernetes_deployment" "wireguard" {
  metadata {
    name = "wireguard"
    labels = {
      name = "wireguard"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "wireguard"
      }
    }

    template {
      metadata {
        labels = {
          name = "wireguard"
        }
      }

      spec {
        volume {
          name = "wireguard-conf"

          config_map {
            name         = "wireguard-conf"
            default_mode = "0644"

            items {
              key  = "wg0.conf"
              path = "wg0.conf"
            }
          }
        }

        volume {
          name = "kernel-modules"

          host_path {
            path = "/lib/modules"
            type = "Directory"
          }
        }

        security_context {
          sysctl {
            name = "net.ipv4.conf.all.src_valid_mark"
            value = 1
          }
        }

        container {
          image = "linuxserver/wireguard:latest"
          name  = "wireguard"

          lifecycle {
            post_start {
              exec {
                # https://github.com/linuxserver/docker-wireguard/issues/205#issuecomment-1308591466
                command = ["cp", "/tmp/wg0.conf", "/config"]
              }
            }
          }

          volume_mount {
            name       = "wireguard-conf"
            mount_path = "/tmp/wg0.conf"
            sub_path   = "wg0.conf"
          }

          volume_mount {
            name       = "kernel-modules"
            mount_path = "/lib/modules"
            read_only  = true
          }

          security_context {
            privileged   = true

            capabilities {
              add = ["SYS_MODULE", "NET_ADMIN"]
            }
          }

          env {
            name = "PUID"
            value = "1000"
          }

          env {
            name = "PGID"
            value = "1000"
          }

          env {
            name = "TZ"
            value = "America/New_York"
          }
        }
      }
    }
  }
}
