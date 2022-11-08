variable "storage" {
  type = string
  description = "Storage directory"
}

resource "docker_volume" "rutorrent_data" {
  name = "rutorrent-data"  
}

resource "docker_volume" "rutorrent_passwd" {
  name = "rutorrent-passwd"  
}

resource "docker_container" "rutorrent" {
  image   = "crazymax/rtorrent-rutorrent:latest"
  name    = "rutorrent"
  restart = "unless-stopped"

  volumes {
    volume_name    = docker_volume.rutorrent_data.name
    container_path = "/data"
  }

  volumes {
    volume_name    = docker_volume.rutorrent_passwd.name
    container_path = "/passwd"
  }

  volumes {
    host_path = var.storage
    container_path = "/downloads"
  }

  // RT DHT
  ports {
    internal = 6881
    external = 6881
    protocol = "udp"
  }

  // XMLRPC
  ports {
    internal = 8000
    external = 8000
  }

  // RUTORRENT
  ports {
    internal = 8080
    external = 8080
  }

  // WEBDAV
  ports {
    internal = 9000
    external = 9000
  }

  // RT INC
  ports {
    internal = 50000
    external = 50000
  }

  env = [
    "PUID=1000",
    "PGID=1000",
  ]

  ulimit {
    name = "nproc"
    soft = 65535
    hard = 65535
  }

  ulimit {
    name = "nofile"
    soft = 32000
    hard = 40000
  }
}

resource "docker_container" "rtorrent_logs" {
  image   = "bash" 
  name    = "rtorrent-logs"
  command = ["bash", "-c", "'tail -f /rutorrent-data/rtorrent/log/*.log'"]
  restart = "unless-stopped"

  volumes {
    volume_name = docker_volume.rutorrent_data.name
    container_path = "/rutorrent-data"
    read_only = true
  }
}
