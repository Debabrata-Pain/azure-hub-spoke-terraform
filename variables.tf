variable "admin_public_ip" {
  type    = string
}

variable "admin_username" {
  type    = string
}
variable "admin_password" {
  sensitive = true
}

variable "public_key" {
  type = string
}

