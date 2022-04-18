# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

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
  lxd_host_public_ipv6          = yamldecode(file(local.host_configuration))["host_public_ipv6"]
  lxd_host_control_ipv4_address = yamldecode(file(local.host_configuration))["host_control_ip"]
  lxd_host_network_part         = yamldecode(file(local.host_configuration))["lxd_host_network_part"]
  lxd_host_public_ipv6_address  = yamldecode(file(local.host_configuration))["host_public_ipv6_address"]
  lxd_host_public_ipv6_prefix   = yamldecode(file(local.host_configuration))["host_public_ipv6_prefix"]
  lxd_host_private_ipv6_prefix  = yamldecode(file(local.host_configuration))["lxd_host_private_ipv6_prefix"]
  lxd_host_network_ipv6_subnet  = yamldecode(file(local.host_configuration))["lxd_host_network_ipv6_subnet"]
}

# Calculated variables
locals {
  lxd_host_ipv6_prefix = ( local.lxd_host_public_ipv6 == true ? local.lxd_host_public_ipv6_prefix : local.lxd_host_private_ipv6_prefix )
}

# Consul variables
locals {
  consul_ip_address  = join("", [ local.lxd_host_ipv6_prefix, "::", local.lxd_host_network_ipv6_subnet, ":1" ])
}
