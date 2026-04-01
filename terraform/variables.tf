variable "hetzner_api_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/homelab.pub"
}

variable "location" {
  description = "Hetzner datacenter location"
  type        = string
  default     = "nbg1" # Falkenstein
}

variable "server_name" {
  description = "Name der VM"
  type        = string
  default     = "homelab"
}

variable "server_type" {
  description = "Hetzner server type"
  type        = string
  default     = "cpx22"
}
