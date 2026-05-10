variable "admin_public_ip" {
  type    = string
  default = null
}

variable "admin_username" {}
variable "admin_password" {
  sensitive = true
  default   = null
}

variable "public_key" {}

