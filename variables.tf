variable "admin_public_ip" {
  type    = string
}

variable "admin_username" {
  type    = string
}
variable "admin_password" {
  type = string
  sensitive = true
}

variable "public_key" {
  type = string
}

variable "env" {
  type = string
}

variable "client_id" {
  sensitive = true
}

variable "client_secret" {
  sensitive = true
}