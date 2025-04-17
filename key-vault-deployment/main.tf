##
# Terraform Configuration
##

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.1, < 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 2.2.0, < 3.0.0"
    }
  }
} 

provider "azapi" {
  # Configuration options
}

provider "azurerm" {
  features {}
  subscription_id = "xxxx-xxxx-xxxx-xxxx"
}

# Get details about the currently authenticated Azure user/service principal
data "azurerm_client_config" "current" {}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

locals {
  azure_regions = [
    "ukwest",
    "westeurope",
    "francecentral",
    "swedencentral"
    # Add other regions as needed
  ]
}

# This picks a random region from the list of regions.
resource "random_integer" "region_index" {
  max = length(local.azure_regions) - 1
  min = 0
}

# This is required for resource modules
resource "azurerm_resource_group" "rg" {
  location = local.azure_regions[random_integer.region_index.result]
  name     = module.naming.resource_group.name_unique

  tags = {
    Environment = var.tag_environment
    Project     = var.tag_project
    Creator     = var.tag_creator
  }
}

# Create an Azure Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                       = module.naming.key_vault.name_unique # must be globally unique
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete"
    ]

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Import",
      "Backup",
      "Restore",
      "GetRotationPolicy",
      "Recover"
    ]
  }
}
