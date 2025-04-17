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
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

provider "azapi" {
  # Configuration options
}

provider "azurerm" {
  features {}
  subscription_id = "XXXX-XXXX-XXXX-XXXX"
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg
}

# Generate a random password
resource "random_password" "password" {
  length  = 20
  special = true
  upper   = true
  numeric = true
}

resource "time_offset" "expiry" {
  offset_days = 30
}

# Store the generated password in the Key Vault
resource "azurerm_key_vault_secret" "passwordstorage" {
  name            = "generated-password"
  value           = random_password.password.result
  key_vault_id    = data.azurerm_key_vault.key_vault.id
  expiration_date = time_offset.expiry.rfc3339
}

resource "azurerm_key_vault_key" "keygeneration" {
  name         = "my-key"
  key_vault_id = data.azurerm_key_vault.key_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["encrypt", "decrypt", "sign", "verify", "wrapKey", "unwrapKey"]

  expiration_date = time_offset.expiry.rfc3339
}
