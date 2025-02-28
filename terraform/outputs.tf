

output "inventory_ansible" {
  depends_on = [proxmox_virtual_environment_vm.ubuntu_vm]
  value = yamlencode({
    all = {
      hosts = {
        for vm in proxmox_virtual_environment_vm.ubuntu_vm : vm.name => {
          ansible_host = vm.ipv4_addresses[1][0]
        }
      }
    }
  })
}

output "inventory_fury" {
  depends_on = [proxmox_virtual_environment_vm.ubuntu_vm]
  value = yamlencode({
    nodes = [
      for tag in distinct(flatten([
        for vm in proxmox_virtual_environment_vm.ubuntu_vm : vm.tags
        ])) : {
        name = tag
        hosts = [
          for vm in proxmox_virtual_environment_vm.ubuntu_vm : {
            name = vm.name
            ip   = vm.ipv4_addresses[1][0]
          } if contains(vm.tags, tag)
        ]
      }
    ]
  })
}