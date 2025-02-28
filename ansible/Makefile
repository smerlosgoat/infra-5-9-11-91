# Makefile for managing Ansible tasks

.PHONY: all install_collections install_roles lint format

# Targets
all: install_collections install_roles lint format

install_collections:
	ansible-galaxy collection install -r collections/requirements.yml --force --collections-path ./collections

install_roles:
	ansible-galaxy install -r roles/requirements.yml --force --roles-path ./roles

lint:
	ansible-lint

format:
	@export YAMLFIX_SEQUENCE_STYLE="block_style"; yamlfix .