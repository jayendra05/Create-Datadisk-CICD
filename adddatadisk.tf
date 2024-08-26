# Configure the Azure provider
provider "azurerm" {
    features {}
  }

# Variables
variable "resource_group_name" {
  type        = string
  default     = "JAYENDRA-CICD-RG"
}

variable "vm_name" {
  type        = string
  default     = "Server-01"
}

variable "location" {
  type        = string
  default     = "East Asia"
}

variable "disk_size_gb" {
  type        = number
  default     = 4
}

variable "disk_name" {
  type        = string
  default     = "Server-01-DataDisk-02"
}

variable "script_url" {
  type        = string
  default     = "https://poswerhsellscript.blob.core.windows.net/poswerhsellscript/InitializeAndFormatDisk.ps1"
}

variable "storage_account_name" {
  type        = string
  default     = "poswerhsellscript"
}

variable "storage_account_key" {
  type        = string
  default     = "ZX2SZs4U3wg77DJF2OuhqFYh7plD7JeTYdXKcvE/L2KV67ChyLlx4fLIqCXXmSmkcCff2P9J62uS+AStAKU/rw=="
}

# Data source to get the existing VM
data "azurerm_virtual_machine" "existing_vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
}

# Define a virtual machine extension for Windows VM
resource "azurerm_virtual_machine_extension" "winrm" {
  name                 = "winrm_conn"
  virtual_machine_id   = data.azurerm_virtual_machine.existing_vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "fileUris": ["${var.script_url}"]
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -File InitializeAndFormatDisk.ps1",
      "storageAccountName": "${var.storage_account_name}",
      "storageAccountKey": "${var.storage_account_key}"
    }
  PROTECTED_SETTINGS
}
