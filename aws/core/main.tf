## Don't forget to update bucket name and dynamodb table
## name with your own platform_code
# terraform {
#  backend "s3" {
#    bucket         = "tfstate-falkenmaze83"
#    key            = "state/terraform.tfstate"
#    region         = "eu-west-1"
#    encrypt        = true
#    kms_key_id     = "alias/tfstate-bucket-key"
#    dynamodb_table = "tfstate-falkenmaze83"
#  }
# }

locals {
  stack_name = "${var.environment}-${var.platform_code}"
  bastion = 0	# 0=disabled / 1=enabled
}

## Declare required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"

      ## Plugin use version constraint syntax
      ## https://developer.hashicorp.com/terraform/language/expressions/version-constraints#version-constraint-syntax
      version = "~> 4"  
    }
  }
}

## Configure the Cloud Provider
provider "aws" {
  region = var.location

  default_tags {
    tags = {
      PlatformCode    = var.platform_code
      Environment     = var.environment
      Terraform       = "true"
    }
  }
}

####
#### Création d'un stockage sécurisé pour le tfstate
####
resource "aws_kms_key" "tfstate-bucket-key" {
 description             = "This key is used to encrypt bucket objects"
 deletion_window_in_days = 10
 enable_key_rotation     = true
}

resource "aws_kms_alias" "key-alias" {
 name          = "alias/tfstate-bucket-key"
 target_key_id = aws_kms_key.tfstate-bucket-key.key_id
}

resource "aws_s3_bucket" "tfstate" {
 bucket = "tfstate-${var.platform_code}"

 server_side_encryption_configuration {
   rule {
     apply_server_side_encryption_by_default {
       kms_master_key_id = aws_kms_key.tfstate-bucket-key.arn
       sse_algorithm     = "aws:kms"
     }
   }
 }

 ## Uncomment the force_destroy below to allow Terraform destroy
 ## this bucket, even if it still contains objects (state file)
 # force_destroy: true
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfstate" {
  depends_on = [aws_s3_bucket_ownership_controls.tfstate]
  bucket = aws_s3_bucket.tfstate.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
 bucket = aws_s3_bucket.tfstate.id

 block_public_acls       = true
 block_public_policy     = true
 ignore_public_acls      = true
 restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate" {
 name           = "tfstate-${var.platform_code}"
 read_capacity  = 20
 write_capacity = 20
 hash_key       = "LockID"

 attribute {
   name = "LockID"
   type = "S"
 }
}


####
#### Création et configuration d'un VPC
####
resource "aws_vpc" "ldz_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "${local.stack_name}-vpc"
  }
}

resource "aws_subnet" "ldz_subnet" {
  vpc_id            = aws_vpc.ldz_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.ldz_vpc.cidr_block, 8, 1)

  tags = {
    Name = "${local.stack_name}-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ldz_vpc.id
}

####
#### Création d'un bastion
####
resource "aws_eip" "ldz_bastion_eip" {
  count = local.bastion
  instance = aws_instance.bastion[0].id
  vpc      = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "bastion-${local.stack_name}-eip"
  }
}

resource "aws_network_interface" "bastion" {
  count = local.bastion
  subnet_id   = aws_subnet.ldz_subnet.id
  private_ips = [cidrhost(aws_subnet.ldz_subnet.cidr_block, 10)]

  tags = {
    Name = "bastion-${local.stack_name}-nic"
  }
}

resource "aws_instance" "bastion" {
  count = local.bastion

  ami           = data.aws_ami.ubuntu.id # cf. data block below
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.bastion[0].id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "bastion-${local.stack_name}-ec2"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
