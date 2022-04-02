variable "WINDOWS_TEMPLATE" {
  default = "TEMPLATE-W2019"
  type    = string
}
variable "WINDOWS_CPU" {
  default = "4"
}
variable "WINDOWS_MEN" {
  default = "4096"
}
variable "WINDOWS_FOLDER" {
  default = "WINDOWS"
}
variable "WINDOWS_VM_NAME" {
  default = "VM-WIN-LAB"
}
variable "WINDOWS_INSTANCE" {
  default = "6"
}
variable "WINDOWS_WORKGROUP" {
  default = "TERRAFORM_LAB"
}
variable "WINDOWS_PASSWORD" {
  default = "Str0ngP@ssw0rd!"

}
variable "WINDOWS_OS" {
  default = "WINDOWS SERVER 2019"

}
variable "WINDOWS_job" {
  default = "GRP JOB1"
}