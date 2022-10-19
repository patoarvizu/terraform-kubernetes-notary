# Terraform Kubernetes Notary module

![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/patoarvizu/terraform-kubernetes-notary.svg) ![Keybase BTC](https://img.shields.io/keybase/btc/patoarvizu.svg) ![Keybase PGP](https://img.shields.io/keybase/pgp/patoarvizu.svg) ![GitHub](https://img.shields.io/github/license/patoarvizu/terraform-kubernetes-notary.svg)

<!-- TOC -->

- [Terraform Kubernetes Notary module](#terraform-kubernetes-notary-module)
    - [Intro](#intro)
    - [Features](#features)
    - [Terraform versions](#terraform-versions)
    - [Examples](#examples)
        - [Create KMS Key](#create-kms-key)
        - [Encrypt passwords, passphrase and certificates.](#encrypt-passwords-passphrase-and-certificates)
        - [Run Notary](#run-notary)
        - [Inputs](#inputs)
        - [Outputs](#outputs)

<!-- /TOC -->

## Intro

[Notary](https://github.com/theupdateframework/notary) is an implementation of [The Update Framework specification](https://github.com/theupdateframework/specification). This module assumes you're already familiar with Notary and its concepts, but if you want to learn about it, you can find good information on the links before or in YouTube videos like [this one](https://www.youtube.com/watch?v=gIFRQObHbZk) or [this one](https://www.youtube.com/watch?v=76S7ZAwM0h4).

## Features

* Create a Kubernetes `Deployment` each for the Notary signer and Notary server components.
* Set database credentials, signer alias and SSL certificates parameters as encrypted KMS strings.
* Configure signer and server parameters like GUN prefixes, caching, authentication options, etc.
* Using placeholders for passwords to set database connection options.
* Supports MySQL and Postgres storage.
* Optionally:
  * Create a persistence layer, deployed in Kubernetes as well, to serve as the storage for both the server and signer.
  * Run migration jobs to initialize the persistence layer.
  * Deploy an `Ingress` to expse the server component externally.

## Terraform versions

This module only supports Terraform version 0.12 (and above).

## Examples

If you want to start from creating a KMS key for encrypting the secrets all the way to launching a full Notary with encrypted secrets, follow this order. Keep in mind that you may need to add your own backend and/or provider credential configurations for these examples to fully work.

### Create KMS Key

The [create-kms-key](examples/create-kms-key) example will create a simple KMS key and a KMS alias pointing to it. The alias name is hard-coded to `alias/notary`.

### Encrypt passwords, passphrase and certificates.

The [get-encrypted-certs-and-passwords](examples/get-encrypted-certs-and-passwords) example will create new TLS certificates for the server and signer, encrypt them with the `alias/notary` alias created in the previous step, as well as taking parameters for the server and signer DB credentials, and the signer's alias passphrase (the `server_db_password`, `signer_db_password`, and `signer_alias_passphrase` parameters respectively), and encrypt them with the same `alias/notary` alias.

This example will output the following values:

* `ca_cert_pem`
* `server_cert_pem`
* `encrypted_server_cert_key`
* `signer_cert_pem`
* `encrypted_signer_cert_key`
* `encrypted_server_db_password`
* `encrypted_signer_db_password`
* `encrypted_signer_alias_passphrase`

The output is formatted such that the values can be copied and pasted exactly as-is on to a `terraform.tfvars` file to be used in the next step.

### Run Notary

Copy the values from the previous step into a `terraform.tfvars` file into the [encrypted-tls](examples/encrypted-tls) example directory, add your custom values (like `gun_prefixes`, `server_image_version`, `signer_image_version`, etc.), and apply Terraform. If you want to have the module create a valid `Ingress`, you have to pass at least one value to `ingress_hosts`. Keep in mind that to correctly expose your service you might need to add other settings such as annotations to create DNS records, which you can also add with `ingress_annotations`. Alternatively, you can provision your own `Ingress` object outside of this module.

Thant's it! If you have a valid hostname/port for the Notary server, you can start interacting with it. The usage of Notary is outside of the scope of this document, but you can go learn more at the links posted above.

### Inputs

Variable | Default | Description
---------|---------|------------
encrypted_server_db_password | | The server user DB password, encrypted with KMS.
encrypted_signer_db_password | | The signer user DB password, encrypted with KMS.
encrypted_signer_alias_passphrase | | The passphrase that the `NOTARY_SIGNER_<signer_default_alias>` environment variable will be set to.
ca_cert_pem | | The CA public certificate, base64-encoded.
server_cert_pem | | The public server certificate, base64-encoded.
encrypted_server_cert_key | | The server private certificate key, encrypted with KMS.
signer_cert_pem | | The public signer certificate, base64-encoded.
encrypted_signer_cert_key | | The signer private certificate key, encrypted with KMS.
storage_class_name | null | The Kubernetes storage class name to use on PersistentVolumeClaims.
ingress_tls_hosts | null | The list of hosts to be added in the tls map of the ingress.
ingress_tls_secret_name | null | The name of the secret that has the certificates valid for the hosts in the `ingress_tls_hosts` variable.
namespace | `default` | The namespace to deploy the resources into.
service_type | `ClusterIP` | Determines how the service is exposed.
deploy_persistence | `true` | Boolean to indicate if this module should deploy the persistence layer. Set to `false` if storage has been provisioned externally.
run_migration_jobs | `true` | Boolean to indicate if the initial migration jobs need to be run. Set to `false` if storage has been initialized externally.
storage_flavor | `mysql` | The 'flavor' of storage. The chart currently only supports `mysql` and `postgres`.
storage_image | `mariadb:10.1.28` | The image to be used for the storage deployment. Only used if `deploy_persistence` is set to `true`.
storage_size | `500Mi` | The size of the requested volume. Only used if `deploy_persistence` is set to `true`.
migrate_version | `v4.6.2` | The version of the `migrate` image to be used for migrating jobs. Only used if `run_migration_jobs` is set to `true`.
server_port | `4443` | The port to expose the server component on.
server_trust_type | `remote` | Type of trust for the server component. Corresponds to the `trust_service.type` field of the server configuration file. Note that even if this is set to `local`, the signer component will still be deployed.`
server_trust_hostname | `notary-signer` | The hostname where the signer component is deployed.
server_trust_port | `7899` | The port where the signer component is deployed.
server_storage_db_url | `server:%% .Env.PASSWORD %%@tcp(notary-db:3306)/notaryserver` | The server storage DB url. Corresponds to the `storage.db_url` field of the server configuration file. The special `%% .Env.PASSWORD %%` placeholder can be used to be replaced by the `PASSWORD` environment variable, to avoid hard-coding plain-text credentials.
server_replicas | `3` | The number of server replicas to run.
server_image_version | `server-0.6.1-2` | The version of the server image to run.
logging_level | `info` | The logging level. It corresponds to the `logging.level` field of both the server and signer configuration files.
authentication_enabled | `false` | Boolean to enable registry authentication.
authentication_type | `""` | Only `token` is supported.
authentication_options | `{}` | Map of authentication options (documented here: https://github.com/docker/distribution/blob/master/docs/configuration.md). These values should match those of the target authentication server, which is outside of the scope of this module.
caching_enabled | `false` | Boolean to indicate if caching is enabled.
caching_current_metadata | `300` | Corresponds to the `caching.max_age.current_metadata` field of the server configuration file.
caching_consistent_metadata | `31536000` | Corresponds to the `caching.max_age.consistent_metadata` field of the server configuration file.
gun_prefixes | `[ "docker.io/", "example.com/" ]` | The list of GUN prefixes that Notary will manage.
signer_port | `7899` | The port where the signer is exposed on.
signer_storage_db_url | `signer:%% .Env.PASSWORD %%@tcp(notary-db:3306)/notarysigner` | The signer storage DB url. Corresponds to the `storage.db_url` field of the server configuration file. The special `%% .Env.PASSWORD %%` placeholder can be used to be replaced by the `PASSWORD` environment variable, to avoid hard-coding plain-text credentials.
signer_default_alias | `alias` | The default alias name, which will be used to discover the default passphrase on the `NOTARY_SIGNER_<signer_default_alias>` environment variable.
signer_replicas | `3` | The number of signer replicas to run.
signer_image_version | `signer-0.6.1-2` | The version of the signer image to run.
ingress_hosts | `[]` | The list of hosts that the ingress will route requests for.
ingress_path | `/` | The path to be used for routing ingress rules to the server component.
ingress_annotations | `{}` | A map of annotations to be added to the ingress.

### Outputs

None
