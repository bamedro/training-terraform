output "storage_name" {
  value = "${azurerm_storage_account.tfbackend.name}"
  sensitive = true
}