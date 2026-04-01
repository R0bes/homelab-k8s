.PHONY: help setup check fix

help:
	@echo "Usage: make <target>"
	@echo "Targets:"
	@echo "  setup - Setup the project"
	@echo "  check - Run pre-commit checks"
	@echo "  fix   - Run pre-commit checks and fix any issues"

setup:
	pre-commit install
	terraform -chdir=terraform init

check:
	pre-commit run --all-files

fix:
	pre-commit run --all-files || true
	git add -u
	pre-commit run --all-files
