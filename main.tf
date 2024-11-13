
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.102.0"
    }
  }
}

provider "azurerm" {
 features {}
}



/*
terraform {
  backend "azurerm" {
    resource_group_name  = "tf-stage-azure-open-ai"
    storage_account_name = "terraformstateopen2024ai"
    container_name       = "terraformopenai2024"
    key                  = "terraform.tfstate"
  }
}*/


resource "azurerm_resource_group" "test_ardagh_rg" {
  name     = "test_ardagh"
  location = "East US"
}

resource "azurerm_virtual_network" "test_ardagh_vnet" {
  name                = "test_ardagh-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_ardagh_rg.location
  resource_group_name = azurerm_resource_group.test_ardagh_rg.name
}

resource "azurerm_subnet" "test_ardagh-subnet" {
  name                 = "test_ardagh-subnet"
  resource_group_name  = azurerm_resource_group.test_ardagh_rg.name
  virtual_network_name = azurerm_virtual_network.test_ardagh_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "test_ardagh_nic" {
  name                = "test_ardagh_nic"
 location            = azurerm_resource_group.test_ardagh_rg.location
 resource_group_name = azurerm_resource_group.test_ardagh_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                    = test_ardagh-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "test_ardagh_" {
  name                = "example-vm"
  location            = azurerm_resource_group.test_ardagh_rg.location
  resource_group_name = azurerm_resource_group.test_ardagh_rg.name
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!" # Ensure this meets Azure's password policy
  network_interface_ids = [
    azurerm_network_interface.test_ardagh_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    create_option        = "FromImage"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_network_interface.test_ardagh_nic.ip_configuration[0].private_ip_address
}
