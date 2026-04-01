terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.54"
    }
  }
  required_version = ">= 1.5.0"
}

provider "hcloud" {
  token = var.hetzner_api_token
}
