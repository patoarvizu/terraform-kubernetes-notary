variable "namespace" {
  type = string
  default = "default"
}

variable "deploy_persistence" {
  type = bool
  default = true
}

variable "storage_flavor" {
  type = string
  default = "mysql"
}

variable "storage_image" {
  type = string
  default = "mariadb:10.1.28"
}

variable "storage_class_name" {
  type = string
  default = "default"
}

variable "storage_size" {
  type = string
  default = "100Mi"
}

variable "migrate_version" {
  type = string
  default = "v4.6.2"
}

variable "server_port" {
  type = number
  default = 4443
}

variable "server_trust_type" {
  type = string
  default = "remote"
}

variable "server_trust_hostname" {
  type = string
  default = "notary-signer"
}

variable "server_trust_port" {
  type = number
  default = 7899
}

variable "server_storage_db_url" {
  type = string
  default = "server:%% .Env.PASSWORD %%@tcp(notary-db:3306)/notaryserver"
}

variable "server_replicas" {
  type = number
  default = 3
}

variable "server_db_password" {
  type = string
  default = "password123"
}

variable "server_image_version" {
  type = string
  default = "server-0.6.1-2"
}

variable "logging_level" {
  type = string
  default = "info"
}

variable "authentication_enabled" {
  type = bool
  default = false
}

variable "authentication_type" {
  type = string
  default = ""
}

variable "authentication_options" {
  type = map
  default = {}
}

variable "caching_enabled" {
  type = bool
  default = false
}

variable "caching_current_metadata" {
  type = number
  default = 300
}

variable "caching_consistent_metadata" {
  type = number
  default = 31536000
}

variable "gun_prefixes" {
  type = list(string)
  default = [
    "docker.io/",
    "example.com/",
  ]
}

variable "signer_port" {
  type = number
  default = 7899
}

variable "signer_storage_db_url" {
  type = string
  default = "signer:%% .Env.PASSWORD %%@tcp(notary-db:3306)/notarysigner"
}

variable "signer_default_alias" {
  type = string
  default = "alias"
}

variable "signer_replicas" {
  type = number
  default = 3
}

variable "signer_db_password" {
  type = string
  default = "password123"
}

variable "signer_image_version" {
  type = string
  default = "signer-0.6.1-2"
}

variable "cert_validity_period_hours" {
  type = number
  default = 8760
}

variable "signer_alias_passphrase" {
  type = string
  default = "password123"
}