variable "dcr_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "workspace_id" {}

variable "vm_ids" {
  type = map(object({
    id      = string
    os_type = string
  }))
}