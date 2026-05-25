resource "azurerm_automation_account" "auto" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "Basic"

  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "automation_vm_contributor" {
  scope                = var.resource_group_id
  role_definition_name = "Contributor"

  principal_id = azurerm_automation_account.auto.identity[0].principal_id
}

resource "azurerm_automation_runbook" "start_vm" {

  name                    = "start-vms"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  log_verbose = true
  log_progress = true

  runbook_type = "PowerShell"

  content = file("${path.root}/scripts/start-vms.ps1")
}

resource "azurerm_automation_runbook" "stop_vm" {

  name                    = "stop-vms"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  log_verbose = true
  log_progress = true

  runbook_type = "PowerShell"

  content = file("${path.root}/scripts/stop-vms.ps1")
}

resource "azurerm_automation_schedule" "start_schedule" {

  name                    = "start-vm-schedule"

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  frequency = "Day"
  interval  = 1

  timezone  = "Asia/Kolkata"

  start_time = "2026-12-25T08:00:00+05:30"

  description = "Start VMs every morning"
}

resource "azurerm_automation_schedule" "stop_schedule" {

  name                    = "stop-vm-schedule"

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  frequency = "Day"
  interval  = 1

  timezone  = "Asia/Kolkata"

  start_time = "2026-12-25T20:00:00+05:30"

  description = "Stop VMs every evening"
}

resource "azurerm_automation_job_schedule" "start_job" {

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  schedule_name = azurerm_automation_schedule.start_schedule.name
  runbook_name  = azurerm_automation_runbook.start_vm.name

  parameters = {
    resourcegroupname = var.resource_group_name
    environment       = var.environment
  }
}

resource "azurerm_automation_job_schedule" "stop_job" {

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  schedule_name = azurerm_automation_schedule.stop_schedule.name
  runbook_name  = azurerm_automation_runbook.stop_vm.name

  parameters = {
    resourcegroupname = var.resource_group_name
    environment       = var.environment
  }
}

resource "azurerm_automation_runbook" "create_snapshot" {

  name                    = "create-snapshot"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  runbook_type = "PowerShell"

  log_verbose  = true
  log_progress = true

  content = file("${path.root}/scripts/create-snapshot.ps1")
}

resource "azurerm_automation_runbook" "delete_snapshot" {

  name                    = "delete-old-snapshots"
  location                = var.location
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  runbook_type = "PowerShell"

  log_verbose  = true
  log_progress = true

  content = file("${path.root}/scripts/delete-old-snapshots.ps1")
}

resource "azurerm_automation_schedule" "snapshot_schedule" {

  name                    = "create-snapshot-schedule"

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  frequency = "Day"
  interval  = 1

  timezone = "Asia/Kolkata"

  start_time = "2026-12-25T01:00:00+05:30"

  description = "Daily VM snapshot creation"
}

resource "azurerm_automation_schedule" "delete_snapshot_schedule" {

  name                    = "delete-old-snapshot-schedule"

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  frequency = "Day"
  interval  = 1

  timezone = "Asia/Kolkata"

  start_time = "2026-12-25T02:00:00+05:30"

  description = "Delete snapshots older than 2 days"
}

resource "azurerm_automation_job_schedule" "snapshot_job" {

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  schedule_name = azurerm_automation_schedule.snapshot_schedule.name
  runbook_name  = azurerm_automation_runbook.create_snapshot.name

  parameters = {
    resourcegroupname = var.resource_group_name
    environment       = var.environment
  }
}

resource "azurerm_automation_job_schedule" "delete_snapshot_job" {

  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.auto.name

  schedule_name = azurerm_automation_schedule.delete_snapshot_schedule.name
  runbook_name  = azurerm_automation_runbook.delete_snapshot.name

  parameters = {
    resourcegroupname = var.resource_group_name
    environment       = var.environment
  }
}

