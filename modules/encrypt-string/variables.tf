variable "text_to_encrypt" {
  type = string
}

variable "kms_alias_name" {
  type = string
  default = "notary"
}