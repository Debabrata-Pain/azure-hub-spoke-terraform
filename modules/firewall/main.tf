resource "azurerm_public_ip" "fw_pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_public_ip" "fw_mgmt_pip" {
  name                = "${var.name}-mgmt-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_firewall_policy" "fw_policy" {

  name                = "${var.name}-policy"

  location            = var.location

  resource_group_name = var.resource_group_name

  sku = "Basic"
}

resource "azurerm_firewall" "fw" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id

  sku_name = "AZFW_VNet"
  sku_tier = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }

  management_ip_configuration {
  name                 = "management-config"
  subnet_id            = var.management_subnet_id
  public_ip_address_id = azurerm_public_ip.fw_mgmt_pip.id
  }
}

resource "azurerm_firewall_network_rule_collection" "network_rules" {
  name                = "network-rules"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name

  priority = 100
  action   = "Allow"

  # Inter-spoke communication
  rule {
    name = "allow-interspoke"

    source_addresses = [
      "10.1.0.0/16",
      "10.2.0.0/16"
    ]

    destination_addresses = [
      "10.1.0.0/16",
      "10.2.0.0/16"
    ]

    destination_ports = ["*"]

    protocols = ["Any"]
  }

  # SSH access
  rule {
    name = "allow-ssh"

    source_addresses = [
      var.admin_public_ip
    ]

    destination_addresses = [
      "10.1.0.0/16",
      "10.2.0.0/16"
    ]

    destination_ports = ["22"]

    protocols = ["TCP"]
  }

  rule {
  name = "allow-internet"

  source_addresses = [
    "10.1.0.0/16",
    "10.2.0.0/16"
  ]

  destination_addresses = [
    "*"
  ]

  destination_ports = [
    "*"
  ]

  protocols = [
    "Any"
  ]
}

}

resource "azurerm_firewall_application_rule_collection" "app_rules" {
  name                = "application-rules"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name

  priority = 200
  action   = "Allow"

  rule {
    name = "allow-web"

    source_addresses = [
      "10.1.0.0/16",
      "10.2.0.0/16"
    ]

    target_fqdns = ["*"]

    protocol {
      port = 80
      type = "Http"
    }

    protocol {
      port = 443
      type = "Https"
    }
  }
}

resource "azurerm_firewall_nat_rule_collection" "dnat_rules" {
  name                = "dnat-rules"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name

  priority = 300
  action   = "Dnat"

  # APP1 VM
  rule {
    name = "app1-ssh"

    source_addresses = [
      var.admin_public_ip
    ]

    destination_addresses = [
      azurerm_public_ip.fw_pip.ip_address
    ]

    destination_ports = ["2221"]

    translated_address = var.app1_private_ip
    translated_port    = "22"

    protocols = ["TCP"]
  }


  # APP2 VM
  rule {
    name = "app2-ssh"

    source_addresses = [
      var.admin_public_ip
    ]

    destination_addresses = [
      azurerm_public_ip.fw_pip.ip_address
    ]

    destination_ports = ["2223"]

    translated_address = var.app2_private_ip
    translated_port    = "22"

    protocols = ["TCP"]
  }

}

resource "azurerm_monitor_diagnostic_setting" "firewall_logs" {
  name                       = "firewall-diagnostics"
  target_resource_id         = azurerm_firewall.fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
  }
}

