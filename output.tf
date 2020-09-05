output "public_ip_address" {
  value = data.azurerm_public_ip.mariadb_client_westeurope.*.ip_address
}
