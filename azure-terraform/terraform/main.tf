resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "lab"
    managed_by  = "terraform"
    project     = "azure-infrastructure"
  }
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-terraform-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  address_space       = var.vnet_address_space

  tags = {
    environment = "lab"
    managed_by  = "terraform"
  }
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = var.subnet_address_prefixes
}

resource "azurerm_network_security_group" "lab" {
  name                = "nsg-terraform-lab"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name

  tags = {
    environment = "lab"
    managed_by  = "terraform"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.lab.id
}
