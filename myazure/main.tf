resource "azurerm_resource_group" "mariadb_client" {
  name     = "resource_group_${var.zone_key}"
  location = var.zone_label
}

resource "azurerm_virtual_network" "mariadb_client" {
  name                = "mariadb_client-${var.zone_key}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mariadb_client.location
  resource_group_name = azurerm_resource_group.mariadb_client.name
}

resource "azurerm_subnet" "mariadb_client" {
  name                 = "internal-${var.zone_key}"
  resource_group_name  = azurerm_resource_group.mariadb_client.name
  virtual_network_name = azurerm_virtual_network.mariadb_client.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "mariadb_client" {
  count = var.instances_count

  name                    = "mariadb_client${count.index}-${var.zone_key}-ip"
  location                = azurerm_resource_group.mariadb_client.location
  resource_group_name     = azurerm_resource_group.mariadb_client.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "mariadb_client" {
  count = var.instances_count
  name                = "mariadb_client${count.index}-${var.zone_key}-nic"
  location            = azurerm_resource_group.mariadb_client.location
  resource_group_name = azurerm_resource_group.mariadb_client.name

  ip_configuration {
    name                          = "internal-${var.zone_key}"
    subnet_id                     = azurerm_subnet.mariadb_client.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mariadb_client[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "mariadb_client" {
  count = var.instances_count
  name                = "mariadb-client${count.index}-${var.zone_key}-cloud"
  resource_group_name = azurerm_resource_group.mariadb_client.name
  location            = azurerm_resource_group.mariadb_client.location
  size                = "Standard_B1ms"
  admin_username      = "epitech"
  network_interface_ids = [
    azurerm_network_interface.mariadb_client[count.index].id,
  ]

  admin_ssh_key {
    username   = "epitech"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.6"
    version   = "latest"
  }

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = azurerm_public_ip.mariadb_client[count.index].ip_address
      user = "epitech"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
    ]
  }

  provisioner "local-exec" {
    command = "echo '${azurerm_public_ip.mariadb_client[count.index].ip_address} ansible_user=${azurerm_linux_virtual_machine.mariadb_client.admin_username} server_id=${var.serverid_prefix}00${count.index}' >> inventory"
  }
}
