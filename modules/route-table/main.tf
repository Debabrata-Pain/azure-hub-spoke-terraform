resource "azurerm_route_table" "rt" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "default_route" {
  name                = "default-route"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.rt.name

  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.firewall_private_ip
}