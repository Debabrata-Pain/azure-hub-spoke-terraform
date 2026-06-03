variable "resource_group_name" {}

variable "subscription_id" {}

variable "environment" {}

variable "vm_ids" {
  type = map(string)
}

variable "alert_email" {}

variable "location" {}

variable "workspace_id" {}

variable "vm_names" {
  type = map(string)
}