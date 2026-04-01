output "server_ip" {
  description = "Public IPv4 address"
  value       = hcloud_server.homelab.ipv4_address
}

output "server_ipv6" {
  description = "Public IPv6 address"
  value       = hcloud_server.homelab.ipv6_address
}
