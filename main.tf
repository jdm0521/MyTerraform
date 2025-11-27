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
  name = "jdm-sg"
  location = azurerm_resource_group.jdm-rg.location
  resource_group_name = azurerm_resource_group.jdm-rg.name

  
}