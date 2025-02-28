variable "proxmox" {
  description = "Proxmox provider configuration"
  sensitive   = true
  type = object({
    endpoint        = string
    username        = string
    password        = string
    tls_insecure    = bool
    node            = string
    default_storage = string
    vm_storage      = string
    default_vbridge = string
    ssh_path        = string
    ssh_user        = string
  })
}

variable "pfsense" {
  description = "pfsense provider configuration"
  sensitive   = true
  type = object({
    url             = string
    password        = string
    tls_skip_verify = bool
  })
}


variable "cloudinit_users" {
  description = "A list of users to configure on the machine."
  type = list(object({
    name : string
    gecos : string
    groups : string
    shell : string
    sudo : list(string)
    ssh_import_id : list(string)
    ssh_authorized_keys : list(string)
  }))
  default = [
    {
      name : "smerlos",
      gecos : "smerlos",
      groups : "sudo, users, admin",
      shell : "/bin/bash",
      sudo : ["ALL=(ALL) NOPASSWD:ALL"],
      ssh_import_id : ["gh:smerlos"]
      ssh_authorized_keys : ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPqutuaRT9OkvUd5Cc1ERPEypAVb0xkDkampOI6O4oWL"]
    }
  ]
}

variable "cloudinit_packages" {
  description = "A list of packages to be installed on the machine."
  type        = list(string)
  default = [
    "open-vm-tools",
    "build-essential",
    "software-properties-common",
    "vim",
    "screen",
    "apt-transport-https",
    "ca-certificates",
    "curl",
    "wget",
    "git",
    "open-iscsi",
    "qemu-guest-agent",
  ]
}

variable "cloudinit_runcmd" {
  description = "A list of commands to execute on the machine."
  type        = list(string)
  default = [
    "systemctl start qemu-guest-agent",
    "ufw disable"
  ]
}

variable "default_gateway" {
  description = "Default gateway for the VMs"
  type        = string
  default     = "192.168.200.1"

}
variable "dns_default_servers" {
  description = "Default dns for the VMs"
  type        = list(string)
  default     = ["192.168.200.1"]
}



variable "dns_default_domain" {
  description = "Default DNS domain for the VMs"
  type        = string
  default     = "compute.internal"
}

variable "proxmox_private_key" {
  type      = string
  sensitive = true
  # No pongas 'default' aquí, así forzamos a que venga de Terraform Cloud.
  description = "Private key used by the Proxmox provider"
}