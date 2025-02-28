terraform {
  cloud {

    organization = "elchivo"

    workspaces {
      name = "vms-promox"
    }
  }
  required_version = "1.11.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.72.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    pfsense = {
      source  = "marshallford/pfsense"
      version = "0.14.0"
    }
  }

}


provider "proxmox" {
  endpoint = var.proxmox.endpoint
  username = var.proxmox.username
  password = var.proxmox.password
  insecure = var.proxmox.tls_insecure
  ssh {
    agent       = false
    username    = var.proxmox.ssh_user
    private_key = var.proxmox_private_key
  }
}

provider "pfsense" {
  url             = var.pfsense.url
  password        = var.pfsense.password
  tls_skip_verify = var.pfsense.tls_skip_verify
}