output "instance_name" {
  value = "instance-${random_pet.instance.id}"
}

# output "tfstate_bucket_name" {
#   value = "${module.tfstate_bucket.bucket_name}"
# }