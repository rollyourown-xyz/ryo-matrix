# Input Variables
#################

variable "host_id" {
  description = "Mandatory: The host_id on which to deploy the project."
  type        = string
}

variable "image_version" {
  description = "Version of the images to deploy - Leave blank for 'terraform destroy'"
  type        = string
}

# Local variables
#################

# Configuration file paths
locals {
  project_configuration               = join("", [ "${abspath(path.root)}/../configuration/configuration_", var.host_id, ".yml"])
  host_configuration                  = join("", [ "${abspath(path.root)}/../../ryo-host/configuration/configuration_", var.host_id, ".yml" ])
  postgres_user_password_file         = join("", [ "${abspath(path.root)}/../../ryo-postgres/configuration/postgres_user_password_", var.host_id, ".yml" ])
  postgres_synapse_user_password_file = join("", [ "${abspath(path.root)}/../configuration/postgres_synapse_user_password_", var.host_id, ".yml" ])
}

# Basic project variables
locals {
  project_id                   = yamldecode(file(local.project_configuration))["project_id"]
  project_domain_name          = yamldecode(file(local.project_configuration))["project_domain_name"]
  project_coturn_domain_name   = yamldecode(file(local.project_configuration))["project_coturn_domain_name"]
  project_admin_username       = yamldecode(file(local.project_configuration))["project_admin_username"]
  project_admin_email          = yamldecode(file(local.project_configuration))["project_admin_email"]
  project_smtp_server          = yamldecode(file(local.project_configuration))["project_smtp_server"]
  project_smtp_server_port     = yamldecode(file(local.project_configuration))["project_smtp_server_port"]
  project_smtp_server_starttls = yamldecode(file(local.project_configuration))["project_smtp_server_starttls"]
  project_smtp_server_ssl      = yamldecode(file(local.project_configuration))["project_smtp_server_ssl"]
  project_smtp_server_username = yamldecode(file(local.project_configuration))["project_smtp_server_username"]
  project_locales              = yamldecode(file(local.project_configuration))["project_locales"]
  project_default_locale       = yamldecode(file(local.project_configuration))["project_default_locale"]
}

# Sensitive variables
locals {
  project_admin_password         = sensitive(yamldecode(file(local.project_configuration))["project_admin_password"])
  project_smtp_server_password   = sensitive(yamldecode(file(local.project_configuration))["project_smtp_server_password"])
  postgres_user_password         = sensitive(yamldecode(file(local.postgres_user_password_file))["postgres_user_password"])
  postgres_synapse_user_password = sensitive(yamldecode(file(local.postgres_synapse_user_password_file))["postgres_synapse_user_password"])
}

# LXD variables
locals {
  lxd_host_public_ipv4_address  = yamldecode(file(local.host_configuration))["host_public_ip"]
  lxd_br0_network_part          = yamldecode(file(local.host_configuration))["lxd_br0_network_part"]
  lxd_host_network_part         = yamldecode(file(local.host_configuration))["lxd_host_network_part"]
}

# Variables from module remote states

data "terraform_remote_state" "ryo-service-proxy" {
  backend = "local"
  config = {
    path = join("", ["${abspath(path.root)}/../../ryo-service-proxy/module-deployment/terraform.tfstate.d/", var.host_id, "/terraform.tfstate"])
  }
}

data "terraform_remote_state" "ryo-postgres" {
  backend = "local"
  config = {
    path = join("", ["${abspath(path.root)}/../../ryo-postgres/module-deployment/terraform.tfstate.d/", var.host_id, "/terraform.tfstate"])
  }
}

locals {
  consul_ip_address   = data.terraform_remote_state.ryo-service-proxy.outputs.consul_ip_address
  postgres_ip_address = data.terraform_remote_state.ryo-postgres.outputs.postgres_ip_address
}

# Output variable definitions

output "synapse-admin_ip_address" {
    description = "IP Address of the synapse-admin container"
    value       = lxd_container.synapse-admin.ip_address
}
