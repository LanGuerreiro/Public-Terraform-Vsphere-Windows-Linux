variable "LINUX_TEMPLATE" {
  default = "TEMPLATE_CENTOS7"
  type    = string
}
variable "LINUX_CPU" {
  default = "1"
}
variable "LINUX_MEN" {
  default = "512"
}
variable "LINUX_FOLDER" {
  default = "LINUX"
}
variable "LINUX_VM_NAME" {
  default = "VM-LNX-LAB"
}
variable "LINUX_VM_DOMAIN" {
  default = "lab-terraform"
}
variable "LINUX_INSTANCE" {
  default = "10"
}
variable "LINUX_USER" {
  default = "root"

}
variable "LINUX_TEMPLATE_PASSWORD" {
  default = "PASS_TEMPLATE"
}
variable "LINUX_OS" {
  default = "CENTOS 7"

}
variable "LINUX_job" {
  default = "GRP JOB2"
}
variable "time_zone" {
  default = "America/Sao_Paulo"

}