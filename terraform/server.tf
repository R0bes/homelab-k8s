resource "hcloud_ssh_key" "default" {
  name       = "homelab-key"
  public_key = file(var.ssh_public_key_path)
}

resource "hcloud_server" "homelab" {
  name         = var.server_name
  server_type  = var.server_type
  image        = "ubuntu-24.04"
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.homelab.id]

  labels = {
    purpose = "homelab-k8s"
  }
}
