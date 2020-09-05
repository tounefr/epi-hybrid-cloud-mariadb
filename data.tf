data "azurerm_public_ip" "mariadb_client" {
  depends_on = [
    azurerm_public_ip.mariadb_client
  ]
  name = "mariadb_client${count.index}-ip"
  count = var.instances_count
  resource_group_name = azurerm_resource_group.mariadb_client.name
}
