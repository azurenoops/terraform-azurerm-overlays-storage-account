# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Private Link for Storage Account Blob - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "table_vnet" {
  count               = var.enable_table_private_endpoint ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "table_pep" {
  count               = var.enable_table_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", element([for n in azurerm_storage_account.storage : n.name], 0))
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.existing_subnet_id
  tags                = merge({ "ResourceName" = format("%s-private-endpoint", element([for n in azurerm_storage_account.storage : n.name], 0)) }, var.add_tags, )

  private_service_connection {
    name                           = "storageaccount-table-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = element([for i in azurerm_storage_account.storage : i.id], 0)
    subresource_names              = ["table"]
  }
}

data "azurerm_private_endpoint_connection" "table_pip" {
  count               = var.enable_table_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.table_pep.0.name
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_storage_account.storage]
}

resource "azurerm_private_dns_zone" "table_dns_zone" {
  count               = var.existing_private_dns_zone == null && var.enable_table_private_endpoint ? 1 : 0
  name                = var.environment == "public" ? "privatelink.table.core.windows.net" : "privatelink.table.core.usgovcloudapi.net"
  resource_group_name = var.resource_group_name
  tags                = merge({ "ResourceName" = format("%s", "StorageAccount-Table-Private-DNS-Zone") }, var.add_tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "table_vnet_link" {
  count                 = var.existing_private_dns_zone == null && var.enable_table_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.table_dns_zone.0.name
  virtual_network_id    = data.azurerm_virtual_network.table_vnet.0.id
  tags                  = merge({ "ResourceName" = format("%s", "vnet-private-zone-link") }, var.add_tags, )
}

resource "azurerm_private_dns_a_record" "table_a_record" {
  count               = var.enable_table_private_endpoint ? 1 : 0
  name                = element([for n in azurerm_storage_account.storage : n.name], 0)
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.table_dns_zone.0.name : var.existing_private_dns_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.table_pip.0.private_service_connection.0.private_ip_address]
}