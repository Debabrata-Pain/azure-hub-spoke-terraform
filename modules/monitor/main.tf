resource "azurerm_monitor_data_collection_rule" "dcr" {

  name                = var.dcr_name
  location            = var.location
  resource_group_name = var.resource_group_name

  kind = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = var.workspace_id
      name                  = "law-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["law-destination"]
  }

  data_sources {

    performance_counter {
      name                          = "perfCounter"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60

      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Memory\\Available Bytes",
        "\\LogicalDisk(_Total)\\% Free Space"
      ]
    }
  }

  description = "Linux VM monitoring DCR"
}

resource "azurerm_virtual_machine_extension" "ama" {
  for_each = var.vm_ids

  name                       = "AzureMonitorAgent"
  virtual_machine_id         = each.value
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_monitor_data_collection_rule_association" "assoc" {
  for_each = var.vm_ids

  name                    = "dcr-association-${each.key}"
  target_resource_id      = each.value
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
}