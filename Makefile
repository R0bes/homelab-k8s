.PHONY: help setup check fix \
		ssh-keygen ssh-login terraform \
		tf-plan tf-up tf-down dns-zone-create \
		ansible-k3s ansible-argocd argocd-pw argocd-ui

-include .env
export

TERRAFORM_DIR := terraform
ANSIBLE_DIR := ansible
SSH_KEY_PATH := $(HOME)/.ssh/homelab
SSH_USER := root
SSH_IP = $(shell terraform -chdir=$(TERRAFORM_DIR) output -raw server_ip 2>/dev/null)



help:
	@echo "Repository commands"
	@echo "		setup 		- Setup the project"
	@echo "		check 		- Run pre-commit checks"
	@echo "		fix   		- Run pre-commit checks and fix any issues"
	@echo ""
	@echo "SSH commands"
	@echo "		ssh-keygen 	- Generate SSH key via SSH key"
	@echo "		ssh-login  	- SSH into server via SSH key"
	@echo ""
	@echo "Terraform commands"
	@echo "		tf-plan  	- Plan Terraform changes"
	@echo "		tf-up    	- Apply Terraform changes"
	@echo "		tf-down  	- Destroy Terraform changes"
	@echo "		dns-zone-create - Bootstrap Hetzner DNS zone (run once)"
	@echo ""
	@echo "Ansible commands"
	@echo "		ansible-k3s 	- Install K3s on server"
	@echo "		ansible-argocd 	- Install ArgoCD on cluster"
	@echo ""
	@echo "ArgoCD commands"
	@echo "		argocd-pw 	- Print ArgoCD admin password"
	@echo "		argocd-ui 	- Port-forward ArgoCD UI to localhost:8080"



# Repo

setup:
	pre-commit install
	terraform -chdir=$(TERRAFORM_DIR) init

check:
	pre-commit run --all-files

fix:
	pre-commit run --all-files || true
	git add -u
	pre-commit run --all-files



# SSH

ssh-keygen:
	ssh-keygen -t ed25519 -C "homelab-k8s" -f $(SSH_KEY_PATH) -N ""
	chmod 600 $(SSH_KEY_PATH)
	@echo "SSH key created: $(SSH_KEY_PATH)"

ssh-login:
	ssh -i $(SSH_KEY_PATH) -o StrictHostKeyChecking=no $(SSH_USER)@$(SSH_IP)



# Terraform

TF_VARS := TF_VAR_hetzner_api_token=$$HETZNER_API_TOKEN

tf-plan:
	$(TF_VARS) terraform -chdir=$(TERRAFORM_DIR) plan

tf-up:
	terraform -chdir=$(TERRAFORM_DIR) init -upgrade -input=false
	$(TF_VARS) terraform -chdir=$(TERRAFORM_DIR) apply -auto-approve

tf-down:
	$(TF_VARS) terraform -chdir=$(TERRAFORM_DIR) destroy


# Ansible

ansible-k3s:
	HOMELAB_IP=$(SSH_IP) ansible-playbook -i $(ANSIBLE_DIR)/inventory/hosts.yml $(ANSIBLE_DIR)/playbooks/k3s-install.yml

ansible-argocd:
	HOMELAB_IP=$(SSH_IP) ansible-playbook -i $(ANSIBLE_DIR)/inventory/hosts.yml $(ANSIBLE_DIR)/playbooks/argocd-install.yml

argocd-pw:
	KUBECONFIG=~/.kube/homelab.yaml kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath='{.data.password}' | base64 -d && echo

argocd-ui:
	KUBECONFIG=~/.kube/homelab.yaml kubectl port-forward -n argocd svc/argocd-server 8080:443


# k8s

k8s-test:
	KUBECONFIG=~/.kube/homelab.yaml kubectl get nodes

k8s-shell:
	@echo "Run: export KUBECONFIG=~/.kube/homelab.yaml"
	@bash --rcfile <(echo 'export KUBECONFIG=~/.kube/homelab.yaml; export PS1="(homelab) \w\$ "')


# Holistic

homelab: tf-up ansible-k3s ansible-argocd
	@echo "✅ Homelab is ready! Run: export KUBECONFIG=~/.kube/homelab.yaml"

homelab-down: tf-down
	@echo "✅ Homelab is down!"
