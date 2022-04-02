data "vsphere_virtual_machine" "template" {
  name          = "/${var.datacenter}/vm/TEMPLATE/${var.WINDOWS_TEMPLATE}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_folder" "folder" {
  path          = "LAB/${var.WINDOWS_FOLDER}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm_WIN" {
  count            = var.WINDOWS_INSTANCE
  name             = "${var.WINDOWS_VM_NAME}-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.WINDOWS_CPU
  memory           = var.WINDOWS_MEN
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = "LAB/${var.WINDOWS_FOLDER}"
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  firmware         = data.vsphere_virtual_machine.template.firmware


  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]


  }

  wait_for_guest_net_timeout  = 10000000000000000
  wait_for_guest_net_routable = false
  wait_for_guest_ip_timeout   = 10000000000000000
  shutdown_wait_timeout       = 10
  migrate_wait_timeout        = 10000000000000000
  force_power_off             = false




  dynamic "disk" {
    for_each = [for s in data.vsphere_virtual_machine.template.disks : {
      label            = index(data.vsphere_virtual_machine.template.disks, s)
      unit_number      = index(data.vsphere_virtual_machine.template.disks, s)
      size             = s.size
      eagerly_scrub    = s.eagerly_scrub
      thin_provisioned = contains(keys(s), "thin_provisioned") ? s.thin_provisioned : "true"
    }]
    content {
      label            = disk.value.label
      unit_number      = disk.value.unit_number
      size             = disk.value.size
      datastore_id     = data.vsphere_datastore.datastore.id
      eagerly_scrub    = disk.value.eagerly_scrub
      thin_provisioned = disk.value.thin_provisioned
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {

      windows_options {

        computer_name  = "${var.WINDOWS_VM_NAME}-${count.index + 1}"
        workgroup      = var.WINDOWS_WORKGROUP
        admin_password = var.WINDOWS_PASSWORD
        //run_once         = ["net user terraform01 Str0ngP@ssw0rd! /ADD", "net user terraform02 Str0ngP@ssw0rd! /ADD"]
      }
      timeout = 60
      network_interface {

        ipv4_address = var.WINDOWS_PRIVETE_IP[count.index + 1]
        ipv4_netmask = 24


      }
      ipv4_gateway    = var.default_GT
      dns_server_list = var.default_DNS

    }
  }
  tags = [
    "${vsphere_tag.tag-environment.id}",
    "${vsphere_tag.tag-windows-OS.id}",
    "${vsphere_tag.tag-windows-backup.id}"

  ]

}

