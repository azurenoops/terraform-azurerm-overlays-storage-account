# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Generic naming variables
variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "use_naming" {
  description = "Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`."
  type        = bool
  default     = true
}

# Custom naming override
variable "storage_account_custom_name" {
  description = "Custom Azure Storage Account name, generated if not set"
  type        = string
  default     = ""
}
variable "use_location_short_name" { 
  description = "Use the short name of the location for the storage account name"
  type        = bool
  default     = true
  
}