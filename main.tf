provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "mariadb_client" {
  name     = "mariadb_client-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "mariadb_client" {
  name                = "mariadb_client-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mariadb_client.location
  resource_group_name = azurerm_resource_group.mariadb_client.name
}

resource "azurerm_subnet" "mariadb_client" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.mariadb_client.name
  virtual_network_name = azurerm_virtual_network.mariadb_client.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "mariadb_client" {
  count = 2

  name                    = "mariadb_client${count.index}-ip"
  location                = azurerm_resource_group.mariadb_client.location
  resource_group_name     = azurerm_resource_group.mariadb_client.name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

resource "azurerm_network_interface" "mariadb_client" {
  count = 2
  name                = "mariadb_client${count.index}-nic"
  location            = azurerm_resource_group.mariadb_client.location
  resource_group_name = azurerm_resource_group.mariadb_client.name

#  depends_on = [
#    azurerm_public_ip.*.mariadb_client.id 
#  ]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mariadb_client.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mariadb_client[count.index].id
  }
}

data "azurerm_public_ip" "mariadb_client" {
  depends_on = [
    azurerm_public_ip.mariadb_client
#    azurerm_linux_virtual_machine.mariadb_client
  ]
#  name                = azurerm_public_ip.mariadb_client[count.index].name
#  depends_on = [
#    azurerm_resource_group.mariadb_client
#  ]
  name = "mariadb_client${count.index}-ip"
  count = 2
  resource_group_name = azurerm_resource_group.mariadb_client.name 
}

resource "azurerm_linux_virtual_machine" "mariadb_client" {
  count = 2
  name                = "mariadb-client${count.index}-cloud"
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
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
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
      "sudo apt update -y || exit 0",
#      "sudo apt install mariadb-server -y",
#      "sudo systemctl stop mariadb",
#      "sudo bash -c \"echo 'server-id = 100' >> /etc/mysql/mariadb.conf.d/50-server.cnf\"",
#      "sudo systemctl start mariadb",
#      "sudo mysql -u root -e \"STOP SLAVE; CHANGE MASTER TO MASTER_HOST='cloud-epitech.thomas-henon.fr', MASTER_USER='epitech',MASTER_PASSWORD='Epitech_1*',MASTER_PORT=3306,MASTER_CONNECT_RETRY=10;START SLAVE;\""
    ]
  }
}

resource "null_resource" "test" {
  count = 2
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = azurerm_public_ip.mariadb_client[count.index].ip_address
      user = "epitech"
      private_key = file("~/.ssh/id_rsa")
    }

    inline = [
      "sudo apt update -y || exit 0",
      "sudo apt install mariadb-server -y",
      "sudo systemctl stop mariadb",
      "sudo bash -c \"echo 'server-id = 10${count.index}' >> /etc/mysql/mariadb.conf.d/50-server.cnf\"",
      "sudo systemctl start mariadb",
#      "sudo mysql -u root -e \"STOP SLAVE; CHANGE MASTER TO MASTER_HOST='cloud-epitech.thomas-henon.fr', MASTER_USER='epitech',MASTER_PASSWORD='Epitech_1*',MASTER_PORT=3306,MASTER_CONNECT_RETRY=10;START SLAVE;\""
    ]
  }

}

output "public_ip_address" {
  value = data.azurerm_public_ip.mariadb_client.*.ip_address
}
