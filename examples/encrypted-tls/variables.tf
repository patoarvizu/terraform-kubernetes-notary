variable "encrypted_server_db_password" {
  type = string
}

variable "encrypted_signer_db_password" {
  type = string
}

variable "encrypted_signer_alias_passphrase" {
  type = string
}

variable "ca_cert_pem" {
  type = string
}

variable "server_cert_pem" {
  type = string
}

variable "encrypted_server_cert_key" {
  type = string
}

variable "signer_cert_pem" {
  type = string
}

variable "encrypted_signer_cert_key" {
  type = string
}

variable "alias_name" {
  type = string
}

variable "storage_flavor" {
  type = string
}

variable "storage_image" {
  type = string
}

variable "server_storage_db_url" {
  type = string
}

variable "signer_storage_db_url" {
  type = string
}

variable "deploy_persistence" {
  type = bool
  default = true
}

variable "run_migration_jobs" {
  type = string
  default = true
}