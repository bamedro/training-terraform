####
#### Création d'un stockage sécurisé pour le tfstate
#### et production du fichier de config Terraform correspondant
####
resource "azurerm_storage_account" "tfbackend" {
  name                      = "${var.platform_code}4tfbackend"
  resource_group_name       = var.resource_group
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = var.storage_replication_type
  enable_https_traffic_only = true
  tags = var.default_tags
}
resource "azurerm_management_lock" "config" {
  name       = "config-lock"
  scope      = azurerm_storage_account.tfbackend.id
  lock_level = "CanNotDelete"
  notes      = "This Storage Account holds config files, including Terraform States"
}

resource "azurerm_storage_container" "tfstates" {
  name                  = "tfstates"
  storage_account_name  = azurerm_storage_account.tfbackend.name
  container_access_type = "private"
}