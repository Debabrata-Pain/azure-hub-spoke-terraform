terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "f2671501-63ad-4140-b3b4-443e5c06ff86"
  tenant_id       = "b24e2927-f763-4eda-b681-1f150c208e21"

  client_id       = var.client_id
  client_secret   = var.client_secret
}