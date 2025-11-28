terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
}

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "jdm-rg" {
  name     = "jdm-terra-resources"
  location = "West Europe"
  tags = {
    environment = "dev"
  }
}


resource "azurerm_virtual_network" "jdm-vn" {
  name                = "jdm-network"
  resource_group_name = azurerm_resource_group.jdm-rg.name
  location            = azurerm_resource_group.jdm-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }

}

resource "azurerm_subnet" "jdm-subnet" {
  name                 = "jdm-subnet"
  resource_group_name  = azurerm_resource_group.jdm-rg.name
  virtual_network_name = azurerm_virtual_network.jdm-vn.name
  address_prefixes     = ["10.123.1.0/24"]

}

resource "azurerm_network_security_group" "jdm-sg" {
  name                = "jdm-sg"
  location            = azurerm_resource_group.jdm-rg.location
  resource_group_name = azurerm_resource_group.jdm-rg.name

  tags = { environment = "dev" }
}

resource "azurerm_network_security_rule" "jdm-dev-rule" {
  name                        = "jdm-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.jdm-rg.name
  network_security_group_name = azurerm_network_security_group.jdm-sg.name
}

#Asscoiate subnet with security group
resource "azurerm_subnet_network_security_group_association" "jdm-sga" {
  subnet_id                 = azurerm_subnet.jdm-subnet.id
  network_security_group_id = azurerm_network_security_group.jdm-sg.id
}

#Public IP
resource "azurerm_public_ip" "jdm-ip" {
  name                = "jdm-ip"
  resource_group_name = azurerm_resource_group.jdm-rg.name
  location            = azurerm_resource_group.jdm-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

#NIC Card
resource "azurerm_network_interface" "jdm-nic" {
  name                = "jdm-nic"
  location            = azurerm_resource_group.jdm-rg.location
  resource_group_name = azurerm_resource_group.jdm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jdm-subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.jdm-ip.id
  }

  tags = { environment = "dev" }
}

#Linux Vm
resource "azurerm_linux_virtual_machine" "jdm-vm" {
  name                = "jdm-vm"
  resource_group_name = azurerm_resource_group.jdm-rg.name
  location            = azurerm_resource_group.jdm-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.jdm-nic.id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/jdmazurekey.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  #What the current image was at the time. If want to change use the az vm image list command for west europe. 
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-lts"
    version   = "16.04.202109281"
  }

   provisioner "local-exec" {
     command = templatefile("windows-ssh-script.tpl", {
      hostname = self.public_ip_address,
      user = "adminuser",
      identityfile = "~/.ssh/jdmazurekey"
     })
     interpreter = [ "Powershell", "-Command" ]
   }

  tags = { environment = "dev" }
}

data "azurerm_public_ip" "jdm-ip-data" {
    name = azurerm_public_ip.jdm-ip.name
    resource_group_name = azurerm_resource_group.jdm-rg.name 
}