variable "vm_id" {
  type = string
}

variable "location" {
  type = string
}

variable "shutdown_time" {
  type = string
  default = "1900"
}

variable "timezone" {
  type = string
  default = "India Standard Time"
}

variable "tags" {
  type = map(string)
  default = {}
}