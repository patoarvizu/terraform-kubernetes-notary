variable "cert_validity_period_hours" {
  type = number
  default = 8760
}

variable "private_key_algorithm" {
  type        = string
  default     = "ECDSA"
}