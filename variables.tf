variable "admin_public_ip" {}

variable "admin_username" {}
variable "admin_password" {
  sensitive = true
}

variable "public_key" {}

