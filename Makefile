.PHONY: help setup check fix \
		ssh-keygen ssh-login terraform \
		tf-plan tf-up tf-down

-include .env
export

TERRAFORM_DIR := terraform
ANSIBLE_DIR := ansible
SSH_KEY_PATH := $(HOME)/.ssh/homelab
SSH_USER := root
SSH_IP := $(shell terraform -chdir=$(TERRAFORM_DIR) output -raw server_ip 2>/dev/null)



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

tf-plan:
	TF_VAR_hetzner_api_token=$$HETZNER_API_TOKEN terraform -chdir=$(TERRAFORM_DIR) plan

tf-up:
	TF_VAR_hetzner_api_token=$$HETZNER_API_TOKEN terraform -chdir=$(TERRAFORM_DIR) apply

tf-down:
	TF_VAR_hetzner_api_token=$$HETZNER_API_TOKEN terraform -chdir=$(TERRAFORM_DIR) destroy
