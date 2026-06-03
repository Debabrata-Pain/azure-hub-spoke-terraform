variable "resource_group_name" {}

variable "subscription_id" {}

variable "environment" {}

variable "vm_ids" {
  type = map(string)
}

variable "alert_email" {}

variable "location" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "vm_names" {
  type = map(string)
}
