
module "rg" {
  source   = "./modules/rg"
  name     = "${var.environment}-hub-spoke-rg"
  location = "Central India"
}

module "hub_vnet" {
  source              = "./modules/vnet"
  name                = "${var.environment}-hub-vnet"
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = ["10.0.0.0/16"]
}

module "spoke1_vnet" {
  source              = "./modules/vnet"
  name                = "${var.environment}-spoke1-vnet"
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = ["10.1.0.0/16"]
}

module "spoke2_vnet" {
  source              = "./modules/vnet"
  name                = "${var.environment}-spoke2-vnet"
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = ["10.2.0.0/16"]
}

module "spoke1_nsg" {
  source              = "./modules/nsg"
  name                = "${var.environment}-spoke1-nsg"
  location            = module.rg.location
  resource_group_name = module.rg.name
}

module "spoke2_nsg" { 
  source              = "./modules/nsg"
  name                = "${var.environment}-spoke2-nsg"
  location            = module.rg.location
  resource_group_name = module.rg.name
}

module "spoke1_app_subnet" {
  source              = "./modules/subnet"
  name                = "${var.environment}-app-subnet1"
  resource_group_name = module.rg.name
  vnet_name           = module.spoke1_vnet.name
  address_prefixes    = ["10.1.1.0/24"]
}

module "spoke1_db_subnet" {
  source              = "./modules/subnet"
  name                = "${var.environment}-db-subnet1"
  resource_group_name = module.rg.name
  vnet_name           = module.spoke1_vnet.name
  address_prefixes    = ["10.1.2.0/24"]
}

module "spoke2_app_subnet" {
  source              = "./modules/subnet"
  name                = "${var.environment}-app-subnet2"
  resource_group_name = module.rg.name
  vnet_name           = module.spoke2_vnet.name
  address_prefixes    = ["10.2.1.0/24"]
}

module "spoke2_db_subnet" {
  source              = "./modules/subnet"
  name                = "${var.environment}-db-subnet2"
  resource_group_name = module.rg.name
  vnet_name           = module.spoke2_vnet.name
  address_prefixes    = ["10.2.2.0/24"]
}

module "firewall_subnet" {
  source              = "./modules/subnet"
  name                = "AzureFirewallSubnet"
  resource_group_name = module.rg.name
  vnet_name           = module.hub_vnet.name
  address_prefixes    = ["10.0.1.0/26"]
}

module "hub_to_spoke1" {
  source                    = "./modules/peering"
  name                      = "${var.environment}-hub-to-spoke1"
  resource_group_name       = module.rg.name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = module.spoke1_vnet.id

   depends_on = [
    module.spoke1_app_subnet,
    module.spoke1_db_subnet
  ]
}

module "spoke1_to_hub" {
  source                    = "./modules/peering"
  name                      = "${var.environment}-spoke1-to-hub"
  resource_group_name       = module.rg.name
  virtual_network_name      = module.spoke1_vnet.name
  remote_virtual_network_id = module.hub_vnet.id

  depends_on = [
    module.spoke1_app_subnet,
    module.spoke1_db_subnet
  ]
}

module "hub_to_spoke2" {
  source                    = "./modules/peering"
  name                      = "${var.environment}-hub-to-spoke2"
  resource_group_name       = module.rg.name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = module.spoke2_vnet.id

  depends_on = [
    module.spoke2_app_subnet,
    module.spoke2_db_subnet
  ]
}

module "spoke2_to_hub" {
  source                    = "./modules/peering"
  name                      = "${var.environment}-spoke2-to-hub"
  resource_group_name       = module.rg.name
  virtual_network_name      = module.spoke2_vnet.name
  remote_virtual_network_id = module.hub_vnet.id

  depends_on = [
    module.spoke2_app_subnet,
    module.spoke2_db_subnet
  ]
}

resource "azurerm_subnet_network_security_group_association" "spoke1_app_assoc" {
  subnet_id                 = module.spoke1_app_subnet.subnet_id
  network_security_group_id = module.spoke1_nsg.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "spoke1_db_assoc" {
  subnet_id                 = module.spoke1_db_subnet.subnet_id
  network_security_group_id = module.spoke1_nsg.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "spoke2_app_assoc" {
  subnet_id                 = module.spoke2_app_subnet.subnet_id
  network_security_group_id = module.spoke2_nsg.nsg_id
}

resource "azurerm_subnet_network_security_group_association" "spoke2_db_assoc" {
  subnet_id                 = module.spoke2_db_subnet.subnet_id
  network_security_group_id = module.spoke2_nsg.nsg_id
}

module "spoke1_rt" {
  source              = "./modules/route-table"
  name                = "${var.environment}-spoke1-rt"
  location            = module.rg.location
  resource_group_name = module.rg.name

  firewall_private_ip = module.firewall.firewall_private_ip
}

module "spoke2_rt" {
  source              = "./modules/route-table"
  name                = "${var.environment}-spoke2-rt"
  location            = module.rg.location
  resource_group_name = module.rg.name

  firewall_private_ip = module.firewall.firewall_private_ip
}

resource "azurerm_subnet_route_table_association" "spoke1_app_rt" {
  subnet_id      = module.spoke1_app_subnet.subnet_id
  route_table_id = module.spoke1_rt.route_table_id
}

resource "azurerm_subnet_route_table_association" "spoke1_db_rt" {
  subnet_id      = module.spoke1_db_subnet.subnet_id
  route_table_id = module.spoke1_rt.route_table_id
}

resource "azurerm_subnet_route_table_association" "spoke2_app_rt" {
  subnet_id      = module.spoke2_app_subnet.subnet_id
  route_table_id = module.spoke2_rt.route_table_id
}

resource "azurerm_subnet_route_table_association" "spoke2_db_rt" {
  subnet_id      = module.spoke2_db_subnet.subnet_id
  route_table_id = module.spoke2_rt.route_table_id
}

module "app1_vm" {
  source = "./modules/vm"

  vm_name             = "${var.environment}-app1-vm"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.spoke1_app_subnet.subnet_id

  admin_username = var.admin_username
  admin_password = var.admin_password 
  public_key     = var.public_key
}

module "app1_vm_shutdown" {
  source = "./modules/vm-autoshutdown"

  vm_id   = module.app1_vm.vm_id
  location = module.rg.location

  shutdown_time = "1900"

  tags = {
    Environment = "Dev"
  }
}

module "db1_vm" {
  source = "./modules/vm"

  vm_name             = "${var.environment}-db1-vm"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.spoke1_db_subnet.subnet_id

  admin_username = var.admin_username
  admin_password = var.admin_password 
  public_key     = var.public_key
}

module "db1_vm_shutdown" {
  source = "./modules/vm-autoshutdown"

  vm_id   = module.db1_vm.vm_id
  location = module.rg.location

  shutdown_time = "1900"

  tags = {
    Environment = "Dev"
  }
}

module "app2_vm" {
  source = "./modules/vm"

  vm_name             = "${var.environment}-app2-vm"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.spoke2_app_subnet.subnet_id

  admin_username = var.admin_username
  admin_password = var.admin_password
  public_key     = var.public_key
}

module "app2_vm_shutdown" {
  source = "./modules/vm-autoshutdown"

  vm_id   = module.app2_vm.vm_id
  location = module.rg.location

  shutdown_time = "1900"

  tags = {
    Environment = "Dev"
  }
}

module "db2_vm" {
  source = "./modules/vm"

  vm_name             = "${var.environment}-db2-vm"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.spoke2_db_subnet.subnet_id

  admin_username = var.admin_username
  admin_password = var.admin_password
  public_key     = var.public_key
}


module "db2_vm_shutdown" {
  source = "./modules/vm-autoshutdown"

  vm_id   = module.db2_vm.vm_id
  location = module.rg.location

  shutdown_time = "1900"

  tags = {
    Environment = "Dev"
  }
}

module "firewall" {
  source              = "./modules/firewall"
  name                = "${var.environment}-hub-firewall"
  location            = module.rg.location
  resource_group_name = module.rg.name

  subnet_id            = module.firewall_subnet.subnet_id
  management_subnet_id = module.firewall_mgmt_subnet.subnet_id

  admin_public_ip = var.admin_public_ip

  app1_private_ip = module.app1_vm.private_ip
  db1_private_ip  = module.db1_vm.private_ip
  app2_private_ip = module.app2_vm.private_ip
  db2_private_ip  = module.db2_vm.private_ip

  log_analytics_workspace_id = module.log_analytics.workspace_id

}

module "firewall_mgmt_subnet" {
  source = "./modules/subnet"
  name   = "AzureFirewallManagementSubnet"

  resource_group_name = module.rg.name
  vnet_name           = module.hub_vnet.name

  address_prefixes = ["10.0.1.64/26"]
}

module "log_analytics" {
  source              = "./modules/log-analytics"
  name                = "${var.environment}-hub-log-workspace"
  location            = module.rg.location
  resource_group_name = module.rg.name
}

module "monitor" {
  source              = "./modules/monitor"
  dcr_name            = "${var.environment}-hub-monitor-dcr"
  location            = module.rg.location
  resource_group_name = module.rg.name

  workspace_id = module.log_analytics.workspace_id

  vm_ids = {
    app1 = module.app1_vm.vm_id
    db1  = module.db1_vm.vm_id
    app2 = module.app2_vm.vm_id
    db2  = module.db2_vm.vm_id
  }
}

module "appgw_subnet" {
  source = "./modules/subnet"

  name                = "${var.environment}-appgw-subnet"
  resource_group_name = module.rg.name
  vnet_name           = module.hub_vnet.name

  address_prefixes = ["10.0.3.0/24"]
}

module "app_gateway" {
  source = "./modules/app-gateway"

  name                = "${var.environment}-hub-appgateway"
  location            = module.rg.location
  resource_group_name = module.rg.name

  subnet_id = module.appgw_subnet.subnet_id

  app1_private_ip = module.app1_vm.private_ip
  app2_private_ip = module.app2_vm.private_ip
}

module "automation" {
  source = "./modules/automation"

  automation_account_name = "${var.environment}-automation-account"

  location            = module.rg.location
  resource_group_name = module.rg.name
  resource_group_id   = module.rg.id
}