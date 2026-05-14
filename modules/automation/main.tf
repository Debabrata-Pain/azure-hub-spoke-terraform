resource "azurerm_automation_account" "auto" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "Basic"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "automation_vm_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"

  principal_id = azurerm_automation_account.auto.identity[0].principal_id
}