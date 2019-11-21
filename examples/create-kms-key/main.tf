resource "aws_kms_key" "key" {}

resource "aws_kms_alias" "alias" {
  name = "alias/notary"
  target_key_id = aws_kms_key.key.id
}