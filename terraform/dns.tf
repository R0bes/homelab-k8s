resource "hcloud_zone" "robschwe" {
  name = "robschwe.de"
  mode = "primary"
}

resource "hcloud_zone_rrset" "root" {
  zone = hcloud_zone.robschwe.name
  name = "@"
  type = "A"
  records = [
    { value = hcloud_server.homelab.ipv4_address }
  ]
}

resource "hcloud_zone_rrset" "wildcard" {
  zone = hcloud_zone.robschwe.name
  name = "*"
  type = "A"
  records = [
    { value = hcloud_server.homelab.ipv4_address }
  ]
}

# Wildcard covers auth.robschwe.de (Keycloak), grafana.*, argocd.*, etc. No extra RRset required for auth.
