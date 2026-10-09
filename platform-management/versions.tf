terraform {
  required_version = ">= 1.12.0, < 2.0.0"

  required_providers {
    alz = {
      source  = "Azure/alz"
      version = "~> 0.21"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.36.0, < 5.0.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azapi" {}

provider "alz" {
  library_references = [{
    path = "platform/alz"
    ref  = "2026.04.2"
    }, {
    custom_url = "${path.root}/lib"
  }]
}