# --- Required

variable "encrypted_server_db_password" {
  type = string
  description = "The server user DB password, encrypted with KMS."
}

variable "encrypted_signer_db_password" {
  type = string
  description = "The signer user DB password, encrypted with KMS."
}

variable "encrypted_signer_alias_passphrase" {
  type = string
  description = "The passphrase that the NOTARY_SIGNER_<signer_default_alias> environment variable will be set to."
}

variable "ca_cert_pem" {
  type = string
  description = "The CA public certificate, base64-encoded."
}

variable "server_cert_pem" {
  type = string
  description = "The public server certificate, base64-encoded."
}

variable "encrypted_server_cert_key" {
  type = string
  description = "The server private certificate key, encrypted with KMS."
}

variable "signer_cert_pem" {
  type = string
  description = "The public signer certificate, base64-encoded."
}

variable "encrypted_signer_cert_key" {
  type = string
  description = "The signer private certificate key, encrypted with KMS."
}

# -- Default null

variable "storage_class_name" {
  type = string
  default = null
  description = "The Kubernetes storage class name to use on PersistentVolumeClaims."
}

variable "ingress_tls_hosts" {
  type = list
  default = null
  description = "The list of hosts to be added in the tls map of the ingress."
}

variable "ingress_tls_secret_name" {
  type = string
  default = null
  description = "The name of the secret that has the certificates valid for the hosts in the 'ingress_tls_hosts' variable."
}

# --- Optional

variable "namespace" {
  type = string
  default = "default"
  description = "The namespace to deploy the resources into."
}

variable "deploy_persistence" {
  type = bool
  default = true
  description = "Boolean to indicate if this module should deploy the persistence layer. Set to false if storage has been provisioned externally."
}

variable "run_migration_jobs" {
  type = bool
  default = true
  description = "Boolean to indicate if the initial migration jobs need to be run. Set to false if storage has been initialized externally."
}

variable "storage_flavor" {
  type = string
  default = "mysql"
  description = "The 'flavor' of storage. The chart currently only supports 'mysql' and 'postgres'."
}

variable "storage_image" {
  type = string
  default = "mariadb:10.1.28"
  description = "The image to be used for the storage deployment. Only used if 'deploy_persistence' is set to true."
}

variable "storage_size" {
  type = string
  default = "500Mi"
  description = "The size of the requested volume. Only used if 'deploy_persistence' is set to true."
}

variable "migrate_version" {
  type = string
  default = "v4.6.2"
  description = "The version of the 'migrate' image to be used for migrating jobs. Only used if 'run_migration_jobs' is set to true."
}

variable "server_port" {
  type = number
  default = 4443
  description = "The port to expose the server component on."
}

variable "server_trust_type" {
  type = string
  default = "remote"
  description = "Type of trust for the server component. Corresponds to the 'trust_service.type' field of the server configuration file. Note that even if this is set to 'local', the signer component will still be deployed."
}

variable "server_trust_hostname" {
  type = string
  default = "notary-signer"
  description = "The hostname where the signer component is deployed."
}

variable "server_trust_port" {
  type = number
  default = 7899
  description = "The port where the signer component is deployed."
}

variable "server_storage_db_url" {
  type = string
  default = "server:%% .Env.PASSWORD %%@tcp(notary-db:3306)/notaryserver"
  description = "The server storage DB url. Corresponds to the 'storage.db_url' field of the server configuration file. The special '%% .Env.PASSWORD %%' placeholder can be used to be replaced by the PASSWORD environment variable, to avoid hard-coding plain-text credentials."
}

variable "server_replicas" {
  type = number
  default = 3
  description = "The number of server replicas to run."
}

variable "server_image_version" {
  type = string
  default = "server-0.6.1-2"
  description = "The version of the server image to run."
}

variable "logging_level" {
  type = string
  default = "info"
  description = "The logging level. It corresponds to the 'logging.level' field of both the server and signer configuration files."
}

variable "authentication_enabled" {
  type = bool
  default = false
  description = "Boolean to enable registry authentication."
}

variable "authentication_type" {
  type = string
  default = ""
  description = "Only 'token' is supported."
}

variable "authentication_options" {
  type = map
  default = {}
  description = "Map of authentication options (documented here: https://github.com/docker/distribution/blob/master/docs/configuration.md#token). These values should match those of the target authentication server, which is outside of the scope of this module."
}

variable "caching_enabled" {
  type = bool
  default = false
  description = "Boolean to indicate if caching is enabled."
}

variable "caching_current_metadata" {
  type = number
  default = 300
  description = "Corresponds to the 'caching.max_age.current_metadata' field of the server configuration file."
}

variable "caching_consistent_metadata" {
  type = number
  default = 31536000
  description = "Corresponds to the 'caching.max_age.consistent_metadata' field of the server configuration file."
}

variable "gun_prefixes" {
  type = list(string)
  default = [
    "docker.io/",
    "example.com/",
  ]
  description = "The list of GUN prefixes that Notary will manage."
}

variable "signer_port" {
  type = number
  default = 7899
  description = "The port where the signer is exposed on."
}

variable "signer_storage_db_url" {
  type = string
  default = "signer:%% .Env.PASSWORD %%@tcp(notary-db:3306)/notarysigner"
  description = "The signer storage DB url. Corresponds to the 'storage.db_url' field of the server configuration file. The special '%% .Env.PASSWORD %%' placeholder can be used to be replaced by the PASSWORD environment variable, to avoid hard-coding plain-text credentials."
}

variable "signer_default_alias" {
  type = string
  default = "alias"
  description = "The default alias name, which will be used to discover the default passphrase on the NOTARY_SIGNER_<signer_default_alias> environment variable."
}

variable "signer_replicas" {
  type = number
  default = 3
  description = "The number of signer replicas to run."
}

variable "signer_image_version" {
  type = string
  default = "signer-0.6.1-2"
  description = "The version of the signer image to run."
}

variable "ingress_hosts" {
  type = list
  default = []
  description = "The list of hosts that the ingress will route requests for."
}

variable "ingress_path" {
  type = string
  default = "/"
  description = "The path to be used for routing ingress rules to the server component."
}

variable "ingress_annotations" {
  type = map
  default = {}
  description = "A map of annotations to be added to the ingress."
}

variable "deployment_annotations_signer" {
  type = map
  default = {}
  description = "A map of annotations to be added to the notary-signer deployment."
}

variable "deployment_annotations_server" {
  type = map
  default = {}
  description = "A map of annotations to be added to the notary-server deployment."
}

variable "deployment_annotations_db" {
  type = map
  default = {}
  description = "A map of annotations to be added to the notary-db deployment."
}

variable "pod_annotations_signer" {
  type = map
  default = {}
  description = "A map of annotations to be added to the notary-signer pods."
}

variable "pod_annotations_server" {
  type = map
  default = {}
  description = "A map of annotations to be added to the notary-server pods."
}

variable "pod_annotations_db" {
  type = map
  default = {}
  description = "A map of annotations to be added to the notary-db pods."
}