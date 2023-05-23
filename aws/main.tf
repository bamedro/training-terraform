locals {
  platform = {
    platform_code = terraform.workspace
    environment = var.environment
    location = var.location
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
module "tf_backend" {
    source = "../modules/aws/tf_backend"
    # source = "github.com/bamedro/training-terraform/modules/aws/tf_backend"
    platform_code = local.platform.platform_code
}

module "vpc" {
    source = "../modules/aws/vpc"
    cidr_block = "172.10.0.0/16"
}

# module "bastion" {
#     source = "../modules/aws/bastion"
#     vpc_id = module.vpc.vpc_id
#     subnet_id = module.vpc.public_subnet_id
#     bastion = 1
# }
