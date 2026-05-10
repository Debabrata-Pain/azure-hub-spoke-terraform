variable "vm_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_username" {}
variable "admin_password" {}

variable "public_key" {
  type = string
}