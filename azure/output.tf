output "instance_name" {
  value = "instance-${random_pet.instance.id}"
}

output "tf_backend_storage_name" {
  value = "${module.tf_backend.storage_name}"
  sensitive = true
}

output "bastion_public_ip" {
  value = "${azurerm_public_ip.bastion.ip_address}"
}