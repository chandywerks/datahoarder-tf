variable "account_id" {
  type      = string
  sensitive = true
  description = "Mullvad account login key"
}

variable "city" {
  type = string 
  description = "Mullvad exit city"
}

provider "mullvad" {
  account_id = var.account_id
}

data "mullvad_city" "peer" {
  name = var.city
}

resource "wireguard_asymmetric_key" "peer" {}

resource "mullvad_wireguard" "peer" {
  public_key = wireguard_asymmetric_key.peer.public_key
}

resource "mullvad_port_forward" "seed" {
  country_code = data.mullvad_city.peer.country_code 
  city_code    = data.mullvad_city.peer.city_code 

  peer = wireguard_asymmetric_key.peer.public_key
}
