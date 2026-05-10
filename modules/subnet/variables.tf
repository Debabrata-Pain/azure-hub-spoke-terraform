variable "name" {}
variable "resource_group_name" {}
variable "vnet_name" {}
variable "address_prefixes" {
  type = list(string)
}
