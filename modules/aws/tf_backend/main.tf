####
#### Création d'un stockage sécurisé pour le tfstate
#### et production du fichier de config Terraform correspondant
####
resource "aws_kms_key" "tfstate-bucket-key" {
 description             = "This key is used to encrypt bucket objects"
 deletion_window_in_days = 10
 enable_key_rotation     = true 
}

resource "aws_kms_alias" "key-alias" {
 name          = "alias/tfstate-${var.platform_code}-bucket-key"
 target_key_id = aws_kms_key.tfstate-bucket-key.key_id
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-${var.platform_code}"

  ## Uncomment the force_destroy below to allow Terraform destroy
  ## this bucket, even if it still contains objects (state file)
  #force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.tfstate-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
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

resource "local_file" "backend_config" {
    filename = "terraform-backend.tf"
    file_permission = "0640"
    content = templatefile(
        "${path.module}/Technical_Architecture_Document.md.tftpl",
        { platform = local.platform})
}

# terraform {
#   backend "s3" {
#     bucket         = "tfstate-falkenmaze83"
#     key            = "state/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     kms_key_id     = "alias/tfstate-falkenmaze83-bucket-key"
#     dynamodb_table = "tfstate-falkenmaze83"
#   }
# }