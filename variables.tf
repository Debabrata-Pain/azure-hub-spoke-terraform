variable "admin_public_ip" {
  type    = string
  default = null
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}
variable "admin_password" {
  sensitive = true
  default   = null
}

variable "public_key" {
  type = string
}

