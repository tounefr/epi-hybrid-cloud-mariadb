output "public_ip_address" {
  value = data.azurerm_public_ip.mariadb_client.*.ip_address
}
