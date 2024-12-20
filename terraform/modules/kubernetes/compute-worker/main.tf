# Create a new VM from a clone
variable "nodes" {}
variable "storage_pool" { type = string }
variable "target_node" { type = string }

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

resource "proxmox_vm_qemu" "kubernetes_talos" {

    # Dynamic provisioning of multiple nodes
    count = length(var.nodes)

    # VM General Settings
    target_node = var.target_node
    name = var.nodes[count.index].node_name
    vmid = var.nodes[count.index].vm_id

    # VM Advanced General Settings
    onboot = true

    # VM OS Settings
    clone = var.nodes[count.index].clone_target

    # VM System Settings
    agent = 0
    
    # VM CPU Settings
    cores = var.nodes[count.index].node_cpu_cores
    sockets = 1
    cpu = "host"    
    
    # VM Memory Settings
    memory = var.nodes[count.index].node_memory

    # VM Network Settings
    network {
        bridge = "vmbr1"
        model  = "virtio"
    }

    # VM Disk Settings
    scsihw = "virtio-scsi-single"
    disks {
        scsi {
            scsi0 {
                disk {
                    size = var.nodes[count.index].node_disk
                    format    = "raw"
                    iothread  = true
                    backup    = false
                    storage   = var.storage_pool
                }
            }
            scsi1 {
                disk {
                    size = var.nodes[count.index].additional_node_disk
                    format    = "raw"
                    iothread  = true
                    backup    = false
                    storage   = var.storage_pool
                }
            }
        }
    }

    # VM Cloud-Init Settings
    os_type = "cloud-init"
    cloudinit_cdrom_storage = var.storage_pool
}

output "vmids" {
  value = [for vm in proxmox_vm_qemu.kubernetes_talos : vm.vmid]
}

output "macaddrs" {
    value = [for vm in proxmox_vm_qemu.kubernetes_talos : lower(tostring(vm.network[0].macaddr))]
}
