# Homelab setup with Kubernetes

IaC for my personal cloud platform.


## Planned Stack

- Terraform + Ansible
- K3s
- ArgoCD
- Traefik + Let's Encrypt
- Keycloak SSO (OIDC) + oauth2-proxy (Forward Auth)
- Prometheus + Grafana


## Status

🚧 Work in Progress - Building this live!

- [ ] Infrastructure provisioning
- [ ] K3s setup
- [ ] ArgoCD
- [ ] Auth + SSO
- [ ] Monitoring
- [ ] Apps migration


## Documentation

### Auth (Keycloak + oauth2-proxy)

1. Bootstrap secrets (see [k8s/keycloak/secret-bootstrap.example.yaml](k8s/keycloak/secret-bootstrap.example.yaml) or run [ansible/playbooks/keycloak-bootstrap-secrets.yml](ansible/playbooks/keycloak-bootstrap-secrets.yml)).
2. Let Argo CD sync `keycloak` (wave 12) then `oauth2-proxy` (wave 13).
3. After changing Argo OIDC client secret, restart: `kubectl rollout restart deployment/argocd-server -n argocd`.

Wildcards in [terraform/dns.tf](terraform/dns.tf) already cover `auth.robschwe.de` and app hosts.
