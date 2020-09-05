data "azurerm_public_ip" "mariadb_client_westeurope" {
  depends_on = [
    azurerm_public_ip.mariadb_client_westeurope
  ]
  name = "mariadb_client_westeurope${count.index}-ip"
  count = var.instances_count
  resource_group_name = azurerm_resource_group.mariadb_client_westeurope.name
}
