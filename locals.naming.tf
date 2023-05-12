# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Local Naming configuration - Default (required). 
#-----------------------------------------------------------

locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_storage_rg.*.resource_group_name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_storage_rg.*.resource_group_location, [""]), 0)
  sa_name = coalesce(var.storage_account_custom_name, lower(data.azurenoopsutils_resource_name.st.result))
}