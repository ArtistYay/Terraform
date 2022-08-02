terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.15.0"
    }
  }
}

provider "azurerm" {
  features {}

  storage_use_azuread = true
}

resource "azurerm_resource_group" "Azure_Sentinel_Lab" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "Azure_Sentinel_VNet" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.Azure_Sentinel_Lab.name

}

resource "azurerm_subnet" "Azure_Sentinel_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.Azure_Sentinel_Lab.name
  virtual_network_name = azurerm_virtual_network.Azure_Sentinel_VNet.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "Azure_Sentinel_Interface" {
  name                = "honeypot-interface"
  location            = var.location
  resource_group_name = azurerm_resource_group.Azure_Sentinel_Lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Azure_Sentinel_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_security_group" "Azure_Sentinel_SG" {
  name                = var.security_group_name
  location            = var.location
  resource_group_name = azurerm_resource_group.Azure_Sentinel_Lab.name

  security_rule = [
    {
      name                                       = "honeypotrule"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "*"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = "*"
      destination_address_prefix                 = "*"
      description                                = "Honeypot will get traffic from everywhere"
      destination_address_prefixes               = null
      destination_application_security_group_ids = null
      destination_port_ranges                    = null
      source_address_prefixes                    = null
      source_application_security_group_ids      = null
      source_port_ranges                         = null
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "HoneypotRuleAssociation" {
  subnet_id                 = azurerm_subnet.Azure_Sentinel_subnet.id
  network_security_group_id = azurerm_network_security_group.Azure_Sentinel_SG.id
}

resource "azurerm_public_ip" "HoneyPotPublicIP" {
  name                = "HoneyPotPublicIP"
  resource_group_name = azurerm_resource_group.Azure_Sentinel_Lab.name
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_log_analytics_workspace" "HoneypotWorkshop" {
  name                = "HoneypotWorkshop"
  location            = var.location
  resource_group_name = azurerm_resource_group.Azure_Sentinel_Lab.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}