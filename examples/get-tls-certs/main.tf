module "tls" {
  source = "../../modules/generated-certificates"
  alias_name = var.alias_name
}