# Create a virtual network within the resource group
resource "azurerm_virtual_network" "core" {
  name                = "${var.platform_code}-vnet"
  resource_group_name = var.resource_group
  location            = var.location
  address_space       = [var.cidr_block]
  tags = var.default_tags
}

resource "azurerm_subnet" "core" {
  name                 = "default-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.core.name
  address_prefixes     = [var.cidr_block]
}

resource "azurerm_network_security_group" "ssh" {
  name                = "${var.platform_code}-nsg"
  resource_group_name = var.resource_group
  location            = var.location

  security_rule {
    name                       = "allowOpsSourceAddress"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*" ## Fixer pour définir l'origine des connexions SSH
    destination_address_prefix = "*"
  }

  tags = var.default_tags
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.core.id
  network_security_group_id = azurerm_network_security_group.ssh.id
}