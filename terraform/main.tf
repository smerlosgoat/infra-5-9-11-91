
resource "local_file" "cloud_init_user_data_file" {
  for_each = local.vms
  content = templatefile("${path.module}/templates/cloud_config.tftpl", {
    hostname      = each.key,
    domain        = var.dns_default_domain,
    fqdn          = "${each.key}.compute.internal",
    users_yaml    = indent(2, yamlencode(var.cloudinit_users)),
    packages_yaml = indent(2, yamlencode(var.cloudinit_packages)),
    runcmd_yaml   = indent(2, yamlencode(var.cloudinit_runcmd))
  })
  filename = yamldecode("${path.module}/cloud-inits/user_data_vm_${each.key}.yml")
}
locals {
  vms = yamldecode(file("${path.module}/vms.yml"))
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each     = local.vms
  content_type = "snippets"
  datastore_id = var.proxmox.default_storage
  node_name    = var.proxmox.node

  source_raw {
    data = local_file.cloud_init_user_data_file[each.key].content

    file_name = "cloud-config_${each.key}.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  stop_on_destroy = true
  for_each        = local.vms
  name            = each.key
  node_name       = var.proxmox.node
  tags            = each.value.tags
  agent {
    enabled = true
  }

  cpu {
    cores   = each.value.cpu_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  disk {
    datastore_id = var.proxmox.vm_storage
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = each.value.disk_size
  }

  initialization {
    datastore_id = var.proxmox.default_storage
    dns {
      servers = var.dns_default_servers
    }
    ip_config {
      ipv4 {
        # address = "dhcp"
        address = lookup(each.value, "dhcp", false) ? "dhcp" : each.value.network_ip
        gateway = lookup(each.value, "dhcp", false) ? "" : var.default_gateway

      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }

  network_device {
    bridge = var.proxmox.default_vbridge
  }

}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = var.proxmox.default_storage
  node_name    = var.proxmox.node

  url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

resource "pfsense_dnsresolver_hostoverride" "dns" {
  depends_on   = [proxmox_virtual_environment_vm.ubuntu_vm]
  for_each     = proxmox_virtual_environment_vm.ubuntu_vm
  host         = each.value.name
  domain       = var.dns_default_domain
  ip_addresses = [each.value.ipv4_addresses[1][0]]
  description  = "DNS override for ${each.key}"
}

