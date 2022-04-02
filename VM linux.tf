data "vsphere_virtual_machine" "template_LNX" {
  name          = "/${var.datacenter}/vm/TEMPLATE/${var.LINUX_TEMPLATE}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}
resource "vsphere_folder" "folder_linux" {
  path          = "LAB/${var.LINUX_FOLDER}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

//Save pem
resource "local_file" "cloud_pem" {
  filename = "./pem/${var.LINUX_VM_NAME}.pem"
  content  = tls_private_key.privateSSH.private_key_pem
  
}
//Save pub
resource "local_file" "cloud_pub" {
  filename = "./pem/${var.LINUX_VM_NAME}.pub"
  content  = tls_private_key.privateSSH.public_key_openssh
  
}

resource "vsphere_virtual_machine" "vm_LNX" {
  count            = var.LINUX_INSTANCE
  name             = "${var.LINUX_VM_NAME}-${count.index + 1}"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.LINUX_CPU
  memory           = var.LINUX_MEN
  guest_id         = data.vsphere_virtual_machine.template_LNX.guest_id
  folder           = "LAB/${var.LINUX_FOLDER}"
  scsi_type        = data.vsphere_virtual_machine.template_LNX.scsi_type
  firmware         = data.vsphere_virtual_machine.template_LNX.firmware

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template_LNX.network_interface_types[0]


  }
  wait_for_guest_net_timeout  = 10000000000000000
  wait_for_guest_net_routable = false
  wait_for_guest_ip_timeout   = 10000000000000000
  shutdown_wait_timeout       = 10
  migrate_wait_timeout        = 10000000000000000
  force_power_off             = false


  dynamic "disk" {
    for_each = [for s in data.vsphere_virtual_machine.template_LNX.disks : {
      label            = index(data.vsphere_virtual_machine.template_LNX.disks, s)
      unit_number      = index(data.vsphere_virtual_machine.template_LNX.disks, s)
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
    template_uuid = data.vsphere_virtual_machine.template_LNX.id

    customize {
      linux_options {
        host_name = "${var.LINUX_VM_NAME}-${count.index + 1}"
        domain    = var.LINUX_VM_DOMAIN
        time_zone = var.time_zone

      }
      timeout = 60
      network_interface {
        ipv4_address = var.LINUX_PRIVETE_IP[count.index + 1]
        ipv4_netmask = "24"
      }

      ipv4_gateway    = var.default_GT
      dns_server_list = var.default_DNS
    }

  }

  tags = [
    "${vsphere_tag.tag-environment.id}",
    "${vsphere_tag.tag-linux-OS.id}",
    "${vsphere_tag.tag-linux-backup.id}"

  ]
provisioner "file" {
  #source = local_file.cloud_pub.content
  source = "./pem/${var.LINUX_VM_NAME}.pub"
  destination = "/tmp/authorized_keys"

  connection {
      type     = "ssh"
      insecure = true
      user     = var.LINUX_USER
      password = var.LINUX_TEMPLATE_PASSWORD
      host     = var.LINUX_PRIVETE_IP[count.index + 1]
    }

}

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      insecure = true
      user     = var.LINUX_USER
      password = var.LINUX_TEMPLATE_PASSWORD
      host     = var.LINUX_PRIVETE_IP[count.index + 1]
    }

    inline = [

      //"echo 'root:${var.LINUX_NEW_PASSWORD}' | chpasswd"
      "mkdir /root/.ssh",
      "mv /tmp/authorized_keys /root/.ssh/authorized_keys",
      "sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "systemctl restart sshd"

    ]

  }

}

