resource "vsphere_tag_category" "tag-environment-category" {
  name        = "Environment"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine"
  ]
}
resource "vsphere_tag_category" "tag-windows-OS-category" {
  name        = "OS"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine"
  ]
}
resource "vsphere_tag_category" "tag-backup-category" {
  name        = "BACKUP"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine"
  ]
}
resource "vsphere_tag" "tag-environment" {
  name        = var.tag-environment[0]
  category_id = vsphere_tag_category.tag-environment-category.id
  description = var.tag-environment[1]
}
resource "vsphere_tag" "tag-windows-OS" {
  name        = var.WINDOWS_OS
  category_id = vsphere_tag_category.tag-windows-OS-category.id
  description = "OPERATIONAL SYSTEM"
}
resource "vsphere_tag" "tag-linux-OS" {
  name        = var.LINUX_OS
  category_id = vsphere_tag_category.tag-windows-OS-category.id
  description = "OPERATIONAL SYSTEM"
}
resource "vsphere_tag" "tag-windows-backup" {
  name        = var.LINUX_job
  category_id = vsphere_tag_category.tag-backup-category.id
  description = "JOB BACKUP"
}
resource "vsphere_tag" "tag-linux-backup" {
  name        = var.WINDOWS_job
  category_id = vsphere_tag_category.tag-backup-category.id
  description = "JOB BACKUP"
}