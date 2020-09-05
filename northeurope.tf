resource "azurerm_resource_group" "mariadb_client_northeurope" {
  name     = "resource_group_northeurope"
  location = "North Europe"
}

resource "azurerm_virtual_network" "mariadb_client_northeurope" {
  name                = "mariadb_client_northeurope-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mariadb_client_northeurope.location
  resource_group_name = azurerm_resource_group.mariadb_client_northeurope.name
}

resource "azurerm_subnet" "mariadb_client_northeurope" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.mariadb_client_northeurope.name
  virtual_network_name = azurerm_virtual_network.mariadb_client_northeurope.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "mariadb_client_northeurope" {
  count = var.instances_count

  name                    = "mariadb_client_northeurope${count.index}-ip"
  location                = azurerm_resource_group.mariadb_client_northeurope.location
  resource_group_name     = azurerm_resource_group.mariadb_client_northeurope.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "mariadb_client_northeurope" {
  count = var.instances_count
  name                = "mariadb_client_northeurope${count.index}-nic"
  location            = azurerm_resource_group.mariadb_client_northeurope.location
  resource_group_name = azurerm_resource_group.mariadb_client_northeurope.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mariadb_client_northeurope.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mariadb_client_northeurope[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "mariadb_client_northeurope" {
  count = var.instances_count
  name                = "mariadb-client${count.index}-northeurope-cloud"
  resource_group_name = azurerm_resource_group.mariadb_client_northeurope.name
  location            = azurerm_resource_group.mariadb_client_northeurope.location
  size                = "Standard_B1ms"
  admin_username      = "epitech"
  network_interface_ids = [
    azurerm_network_interface.mariadb_client_northeurope[count.index].id,
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
      host = azurerm_public_ip.mariadb_client_northeurope[count.index].ip_address
      user = "epitech"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
    ]
  }

  provisioner "local-exec" {
    command = "echo '${azurerm_public_ip.mariadb_client_northeurope[count.index].ip_address} server_id=100${count.index}' >> inventory"
  }
}
