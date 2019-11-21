variable "server_db_password" {
  type = string
}

variable "signer_db_password" {
  type = string
}

variable "signer_alias_passphrase" {
  type = string
}

variable "kms_alias_name" {
  type = string
  default = "notary"
}