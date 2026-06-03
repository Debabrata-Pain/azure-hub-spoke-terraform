resource "azurerm_monitor_action_group" "alerts" {

  name                = "${var.environment}-action-group"
  resource_group_name = var.resource_group_name

  short_name = "alerts"

  email_receiver {
    name          = "admin"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_activity_log_alert" "vm_started" {
  name                = "${var.environment}-vm-started"
  location            = "Global"
  resource_group_name = var.resource_group_name

  scopes = [
    "/subscriptions/${var.subscription_id}"
  ]

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/start/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_activity_log_alert" "vm_deallocated" {
  name                = "${var.environment}-vm-deallocated"
  location            = "Global"

  resource_group_name = var.resource_group_name

  scopes = [
    "/subscriptions/${var.subscription_id}"
  ]

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/deallocate/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_activity_log_alert" "vm_restart" {

  name                = "${var.environment}-vm-restart-alert"
  location            = "Global"
  resource_group_name = var.resource_group_name

  scopes = [
    "/subscriptions/${var.subscription_id}"
  ]

  criteria {

    category = "Administrative"

    operation_name = "Microsoft.Compute/virtualMachines/restart/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_activity_log_alert" "vm_redeploy" {
  name                = "${var.environment}-vm-redeploy"
  location            = "Global"
  resource_group_name = var.resource_group_name

  scopes = [
    "/subscriptions/${var.subscription_id}"
  ]

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/redeploy/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_activity_log_alert" "vm_delete" {

  name                = "${var.environment}-vm-delete-alert"
  location            = "Global"
  resource_group_name = var.resource_group_name

  scopes = [
    "/subscriptions/${var.subscription_id}"
  ]

  criteria {

    category = "Administrative"

    operation_name = "Microsoft.Compute/virtualMachines/delete"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "cpu80" {

  for_each = var.vm_ids

  name                = "${each.key}-cpu80"
  resource_group_name = var.resource_group_name

  scopes = [
    each.value
  ]

  description = "CPU >80%"

  criteria {

    metric_namespace = "Microsoft.Compute/virtualMachines"

    metric_name = "Percentage CPU"

    aggregation = "Average"

    operator = "GreaterThan"

    threshold = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }

  frequency   = "PT5M"
  window_size = "PT5M"
}

resource "azurerm_monitor_metric_alert" "cpu90" {

  for_each = var.vm_ids

  name                = "${each.key}-cpu90"
  resource_group_name = var.resource_group_name

  scopes = [
    each.value
  ]

  description = "CPU >90%"

  criteria {

    metric_namespace = "Microsoft.Compute/virtualMachines"

    metric_name = "Percentage CPU"

    aggregation = "Average"

    operator = "GreaterThan"

    threshold = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }

  frequency   = "PT5M"
  window_size = "PT5M"
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "memory80" {

  for_each = var.vm_names

  name                = "${each.key}-memory80"
  location            = var.location
  resource_group_name = var.resource_group_name

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  scopes = [
    var.workspace_id
  ]

  severity = 2

  criteria {

    query = <<QUERY
InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "Memory"
| where Name == "AvailableMB"
| where Computer == "${each.value}"
| summarize AvgValue = avg(Val) by bin(TimeGenerated, 5m)
QUERY

    operator  = "LessThan"
    threshold = 1024

    time_aggregation_method = "Average"
  }

  action {
    action_groups = [
      var.action_group_id
    ]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "memory90" {

  for_each = var.vm_names

  name                = "${each.key}-memory90"
  location            = var.location
  resource_group_name = var.resource_group_name

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  scopes = [
    var.workspace_id
  ]

  severity = 0

  criteria {

    query = <<QUERY
InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "Memory"
| where Name == "AvailableMB"
| where Computer == "${each.value}"
| summarize AvgValue = avg(Val) by bin(TimeGenerated, 5m)
QUERY

    operator  = "LessThan"
    threshold = 512

    time_aggregation_method = "Average"
  }

  action {
    action_groups = [
      var.action_group_id
    ]
  }
}

