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


#checkov:skip=CKV_AZURE_220: Azure Firewall Basic SKU does not support IDPS
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

  threat_intel_mode = "Deny"

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

  resource "azurerm_firewall_policy_rule_collection_group" "fw_rules" {

    name               = "fw-rule-group"
    firewall_policy_id = azurerm_firewall_policy.fw_policy.id

    priority = 100

  # ==================================================
  # NAT RULE COLLECTION
  # ==================================================

    nat_rule_collection {
      name     = "dnat-rules"
      priority = 100
      action   = "Dnat"

      # APP1 VM
      rule {
        name = "app1-ssh"

        protocols = ["TCP"]

        source_addresses = [
          var.admin_public_ip
        ]

        destination_address = azurerm_public_ip.fw_pip.ip_address

        destination_ports = ["2221"]

        translated_address = var.app1_private_ip
        translated_port    = "22"
      }

    # APP2 VM
    rule {
      name = "app2-ssh"

      protocols = ["TCP"]

      source_addresses = [
        var.admin_public_ip
      ]

      destination_address = azurerm_public_ip.fw_pip.ip_address

      destination_ports = ["2223"]

      translated_address = var.app2_private_ip
      translated_port    = "22"
    }

    # DB1 VM
    rule {
      name = "db1-ssh"

      protocols = ["TCP"]

      source_addresses = [
        var.admin_public_ip
      ]

      destination_address = azurerm_public_ip.fw_pip.ip_address

      destination_ports = ["2225"]

      translated_address = var.db1_private_ip
      translated_port    = "22"
    }

    # DB2 VM
    rule {
      name = "db2-ssh"

      protocols = ["TCP"]

      source_addresses = [
        var.admin_public_ip
      ]

      destination_address = azurerm_public_ip.fw_pip.ip_address

      destination_ports = ["2227"]

      translated_address = var.db2_private_ip
      translated_port    = "22"
    }
  }

# ==================================================
  # NETWORK RULE COLLECTION
  # ==================================================

 network_rule_collection {
    name     = "network-rule"
    priority = 200
    action   = "Allow"

    # Inter-spoke communication
    rule {
      name = "allow-interspoke"

      protocols = ["Any"]

      source_addresses = [
        "10.1.0.0/16",
        "10.2.0.0/16"
      ]

      destination_addresses = [
        "10.1.0.0/16",
        "10.2.0.0/16"
      ]

      destination_ports = ["*"]
    }

    # SSH access
    rule {
      name = "allow-ssh"

      protocols = ["TCP"]

      source_addresses = [
        var.admin_public_ip
      ]

      destination_addresses = [
        "10.1.0.0/16",
        "10.2.0.0/16"
      ]

      destination_ports = ["22"]
    }

    # Internet access
    rule {
      name = "allow-internet"

      protocols = ["Any"]

      source_addresses = [
        "10.1.0.0/16",
        "10.2.0.0/16"
      ]

      destination_addresses = [
        "*"
      ]

      destination_ports = ["*"]
    }
  }


# ==================================================
  # APPLICATION RULE COLLECTION
  # ==================================================

  application_rule_collection {
    name     = "app-rule"
    priority = 300
    action   = "Allow"

    rule {
      name = "allow-web"

      source_addresses = [
        "10.1.0.0/16",
        "10.2.0.0/16"
      ]

      destination_fqdns = ["*"]

      protocols {
        port = 80
        type = "Http"
      }

      protocols {
        port = 443
        type = "Https"
      }
    }
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

