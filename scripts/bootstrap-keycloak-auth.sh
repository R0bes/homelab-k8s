#!/usr/bin/env bash
# Run from a machine that can reach the cluster (e.g. export KUBECONFIG=~/.kube/homelab.yaml).
# Creates namespaces and secrets for Keycloak, Grafana OIDC, and Argo CD OIDC; then hints for sync/restart.

set -euo pipefail

KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/homelab.yaml}"
export KUBECONFIG

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "error: kubectl cannot reach the cluster (KUBECONFIG=${KUBECONFIG})" >&2
  exit 1
fi

rand() { openssl rand -base64 32 | tr -d '\n'; }

ADMIN_PW="$(rand)"
GRAFANA_SECRET="$(rand)"
ARGOCD_SECRET="$(rand)"

echo "Creating namespaces..."
kubectl create namespace auth --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "Creating keycloak-admin..."
kubectl create secret generic keycloak-admin -n auth \
  --from-literal=admin-password="${ADMIN_PW}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating keycloak-config-cli-env..."
kubectl create secret generic keycloak-config-cli-env -n auth \
  --from-literal=GRAFANA_CLIENT_SECRET="${GRAFANA_SECRET}" \
  --from-literal=ARGOCD_CLIENT_SECRET="${ARGOCD_SECRET}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating grafana-oauth in monitoring..."
kubectl create secret generic grafana-oauth -n monitoring \
  --from-literal=client-secret="${GRAFANA_SECRET}" \
  --dry-run=client -o yaml | kubectl apply -f -

PATCH_FILE="$(mktemp)"
trap 'rm -f "${PATCH_FILE}"' EXIT
python3 -c "import json,sys; print(json.dumps({'stringData':{'oidc.keycloak.clientSecret':sys.argv[1]}}))" "${ARGOCD_SECRET}" >"${PATCH_FILE}"

echo "Patching argocd-secret (OIDC client secret)..."
if kubectl get secret argocd-secret -n argocd >/dev/null 2>&1; then
  kubectl patch secret argocd-secret -n argocd --type merge --patch-file "${PATCH_FILE}"
else
  echo "warning: argocd-secret not found (Argo CD not installed yet?). Patch manually after install." >&2
fi

echo ""
echo "Done. Keycloak admin password is in secret keycloak-admin (namespace auth)."
echo "  kubectl get secret keycloak-admin -n auth -o jsonpath='{.data.admin-password}' | base64 -d; echo"
echo ""
echo "Next (if Argo CD manages these apps):"
echo "  kubectl rollout restart deployment/argocd-server -n argocd"
echo "Or sync apps keycloak -> oauth2-proxy -> traefik -> kube-prometheus-stack in Argo CD UI."
echo ""
