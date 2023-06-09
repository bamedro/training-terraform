locals {
  platform = {
    platform_code = terraform.workspace
    environment = var.environment
    location = var.location
  }

  default_tags = {
    PlatformCode    = local.platform.platform_code
    Environment     = local.platform.environment
    Deployer        = "Terraform"
  }
}

resource "random_pet" "instance" {
    length = 2
}


##
## Technical Architecture Document (TAD)
##
resource "local_file" "tad_content" {
    filename = "TAD-${local.platform.platform_code}.md"
    file_permission = "0640"
    content = templatefile(
        "${path.module}/../Technical_Architecture_Document.md.tftpl",
        { platform = local.platform})
}

resource "local_file" "tad_sha256" {
    filename = replace(local_file.tad_content.filename, ".md", ".sha256")
    file_permission = "0640"
    content = local_file.tad_content.content_sha256
}


##
## Landing Zone avec Bastion
##
resource "azurerm_resource_group" "core" {
  name     = "${local.platform.platform_code}-core-rg"
  location = local.platform.location
  tags = local.default_tags
}

module "tf_backend" {
    source = "../modules/azure/tf_backend"
    # source = "github.com/bamedro/training-terraform/modules/azure/tf_backend"
    resource_group = azurerm_resource_group.core.name
    platform_code = local.platform.platform_code
    storage_replication_type = "LRS"
    default_tags = local.default_tags
}

module "vnet" {
    source = "../modules/azure/vnet"
    resource_group = azurerm_resource_group.core.name
    platform_code = local.platform.platform_code
    cidr_block = "172.10.0.0/16"
    default_tags = local.default_tags
}

resource "azurerm_public_ip" "bastion" {
  name                = "bastion-${local.platform.platform_code}-pip"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  allocation_method   = "Static"

  tags = local.default_tags
}

resource "azurerm_network_interface" "bastion" {
  name                = "bastion-${local.platform.platform_code}-nic"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id 
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "bastion-${local.platform.platform_code}-vm"
  resource_group_name = azurerm_resource_group.core.name
  location            = azurerm_resource_group.core.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
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

  tags = local.default_tags
}

