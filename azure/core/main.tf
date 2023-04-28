## ETAPE 1
## 
## La première fois, se rendre dans le même dossier que ce fichier puis lancer la commande 
## > terraform init 
##
## Se connecter à Azure (sauf si lancé depuis un Cloud Shell du portail Azure)
## > az login
## > az account set --name NomDeLaSouscription
##
## Déployer cette infrastructure avec la commande
## > terraform plan
## puis
## > terraform apply
##

## ETAPE 3 ( L'étape 2 se trouve à la fin de ce fichier)
## Retirer les commentaires simples des lignes ci-dessous
## Lancer les commandes 
## > terraform init
##
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "votrenom1234-core-config"
#     storage_account_name = "votrenom1234"
#     container_name       = "tfstates"
#     key                  = "core.votrenom1234.terraform.tfstate"
#   }
# }

locals {
  default_tags = {
    PlatformCode    = var.platform_code
    Environment     = var.environment
    Terraform       = "true"
  }
}

# Declare required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.9.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "core" {
  name     = "${var.platform_code}-core"
  location = var.location
  tags = local.default_tags
}

####
#### Stockage pour les configs du coeur de l'infrastructure (core)
####
resource "azurerm_storage_account" "coreconfig" {
  name                      = "${var.platform_code}coreconfig"
  resource_group_name       = azurerm_resource_group.core.name
  location                  = azurerm_resource_group.core.location
  account_tier              = "Standard"
  account_replication_type  = var.storage_replication_type
  enable_https_traffic_only = true
  tags = local.default_tags
}
resource "azurerm_management_lock" "config" {
  name       = "config-lock"
  scope      = azurerm_storage_account.coreconfig.id
  lock_level = "CanNotDelete"
  notes      = "This Storage Account holds config files, including Terraform States"
}

resource "azurerm_storage_container" "tfstates" {
  name                  = "tfstates"
  storage_account_name  = azurerm_storage_account.coreconfig.name
  container_access_type = "private"
}


####
#### VNet privé pour les applications
####
resource "azurerm_virtual_network" "core" {
  name                = "${azurerm_resource_group.core.name}-vnet"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  address_space       = ["10.1.0.0/16"]
  tags = local.default_tags
}



####
#### Création d'un bastion (Micro VM Linux)
####

# Create a resource group for bastion environment
resource "azurerm_resource_group" "bastion" {
  name     = "${var.platform_code}-bastion"
  location = var.location
  tags = local.default_tags
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "bastion" {
  name                = "${azurerm_resource_group.bastion.name}-vnet"
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  address_space       = ["10.250.0.0/29"]
  tags = local.default_tags
}

resource "azurerm_virtual_network_peering" "bastion-core" {
  name                      = "${azurerm_resource_group.bastion.name}-vnetpeer"
  resource_group_name       = azurerm_resource_group.bastion.name
  virtual_network_name      = azurerm_virtual_network.bastion.name
  remote_virtual_network_id = azurerm_virtual_network.core.id
}

resource "azurerm_subnet" "bastion" {
  name                 = "${azurerm_resource_group.bastion.name}-subnet"
  resource_group_name  = azurerm_resource_group.bastion.name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = ["10.250.0.0/29"]
}

resource "azurerm_network_security_group" "bastion" {
  name                = "${azurerm_resource_group.bastion.name}-nsg"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name

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

  tags = local.default_tags
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_network_interface" "bastion" {
  name                        = "${azurerm_resource_group.bastion.name}-nic"
  location                    = azurerm_resource_group.bastion.location
  resource_group_name         = azurerm_resource_group.bastion.name

  ip_configuration {
    name                          = "${azurerm_resource_group.bastion.name}-ipconfig"
    subnet_id                     = azurerm_subnet.bastion.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = "${azurerm_resource_group.bastion.name}-pip"
  location            = azurerm_resource_group.bastion.location
  resource_group_name = azurerm_resource_group.bastion.name
  allocation_method   = "Static"
  domain_name_label   = "${azurerm_resource_group.bastion.name}"
  sku                 = "Standard"

  tags = local.default_tags
}

## ETAPE 2
## Retirer les commentaires simples des lignes ci-dessous
## Lancer la commande 
## > terraform plan
## puis
## > terraform apply
##
# resource "azurerm_linux_virtual_machine" "bastion" {
#   name                  = "${azurerm_resource_group.bastion.name}-vm"
#   location              = azurerm_resource_group.bastion.location
#   resource_group_name   = azurerm_resource_group.bastion.name
#   network_interface_ids = [azurerm_network_interface.bastion.id]
#   size                  = "Standard_B2s"
#   admin_username        = "opsadmin"

#   admin_ssh_key {
#     username   = "opsadmin"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "20.04-LTS"
#     version   = "latest"
#   }

#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   tags = local.default_tags
# }
