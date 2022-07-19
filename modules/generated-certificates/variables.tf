variable "cert_validity_period_hours" {
  type = number
  default = 8760
}

variable "private_key_algorithm" {
  type = string
  default = "ECDSA"
}

variable "ecdsa_curve" {
  type = string
  default = null
}

variable "rsa_bits" {
  type = number
  default = null
}

variable "ca_cert_key" {
  type = string
  default = null
}

variable "kms_alias_name" {
  type = string
}

variable "subject_alternative_names_server" {
  type = list
  default = []
  description = "List of subject alternative names for the server certificate."
}

variable "subject_alternative_names_signer" {
  type = list
  default = []
  description = "List of subject alternative names for the signer certificate."
}