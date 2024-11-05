# modules/database/main.tf
variable "vm_id_min" { type = number }
variable "vm_id_max" { type = number }
variable "storage_pool" { type = string }
variable "target_node" { type = string }
variable "postgresql_ct_template" { type = string }

terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

# Define PostgreSQL VM
resource "proxmox_lxc" "postgresql" {
  vmid       = var.vm_id_min
  hostname   = "postgresql"
  ostemplate = "${var.storage_pool}:vztmpl/${var.postgresql_ct_template}"
  target_node = var.target_node
  cores      = 2
  memory     = 4096
  rootfs {
    storage = var.storage_pool
    size    = "96G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "dhcp"
  }
  password = "password"
}