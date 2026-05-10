terraform {
  backend "azurerm" {
    resource_group_name  = "TF-2.0-ResourceGroup"     # Can be passed via `-backend-config=`"resource_group_name=<resource group name>"` in the `init` command.
    storage_account_name = "debstorageaccountbackend" # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "newtfstate"               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "dev.terraform.tfstate"    # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.

    use_azuread_auth = true
  }
}