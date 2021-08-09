# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
