#!/usr/bin/env bash
# Installs Docker (for Floci only), Terraform and AWS CLI v2 on the VM.
# Safe to re-run: each step is skipped when the tool is already there.
set -euo pipefail

TERRAFORM_VERSION="1.16.6"

log() { echo "[install-tools] $*"; }
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

command -v curl >/dev/null && command -v unzip >/dev/null \
  || sudo apt-get install -y curl unzip ca-certificates

install_docker() {
  if command -v docker >/dev/null && docker compose version >/dev/null 2>&1; then
    log "docker already installed: $(docker --version)"
  else
    sudo apt-get update -y
    sudo apt-get install -y docker.io docker-compose-v2
    sudo systemctl enable --now docker
    log "docker installed: $(docker --version)"
  fi
  id -nG "$USER" | grep -qw docker || sudo usermod -aG docker "$USER"
}

install_terraform() {
  if terraform version 2>/dev/null | head -1 | grep -qx "Terraform v${TERRAFORM_VERSION}"; then
    log "terraform already at v${TERRAFORM_VERSION}"
    return
  fi
  local zip="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  local base="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}"
  curl -fsSL -o "$tmp/$zip" "$base/$zip"
  curl -fsSL -o "$tmp/SHA256SUMS" "$base/terraform_${TERRAFORM_VERSION}_SHA256SUMS"
  (cd "$tmp" && grep " ${zip}\$" SHA256SUMS | sha256sum -c -)
  sudo unzip -o "$tmp/$zip" terraform -d /usr/local/bin
  log "terraform installed: $(terraform version | head -1)"
}

install_awscli() {
  if aws --version 2>&1 | grep -q '^aws-cli/2\.'; then
    log "aws cli already installed: $(aws --version 2>&1)"
    return
  fi
  curl -fsSL -o "$tmp/awscli.zip" https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
  unzip -q "$tmp/awscli.zip" -d "$tmp"
  sudo "$tmp/aws/install" --update
  log "aws cli installed: $(aws --version 2>&1)"
}

install_docker
install_terraform
install_awscli
log "done. If docker was just installed, run: newgrp docker"
