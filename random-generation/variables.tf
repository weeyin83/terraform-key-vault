##
# Variables
##

variable "key_vault_rg" {
  description = "The resource group name of the key vault"
  type        = string
  default     = "rg-rk77"
}

variable "key_vault_name" {
  description = "The name of the key vault"
  type        = string
  default     = "kv-rk77"
}
