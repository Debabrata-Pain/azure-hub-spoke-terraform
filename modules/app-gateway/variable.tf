variable "name" {}
variable "location" {}
variable "resource_group_name" {}

variable "subnet_id" {}

variable "app1_private_ip" {}
variable "app2_private_ip" {}

variable "ssl_certificate_secret_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}