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
  project_configuration = join("", ["${abspath(path.root)}/../configuration/configuration_", var.host_id, ".yml"])
  host_configuration    = join("", ["${abspath(path.root)}/../../ryo-host/configuration/configuration_", var.host_id, ".yml" ])
}

# Basic project variables
locals {
  project_id          = yamldecode(file(local.project_configuration))["project_id"]
  ## example_variable = yamldecode(file(local.project_configuration))["example"]
}

# LXD variables
locals {
  lxd_host_public_ipv4_address  = yamldecode(file(local.host_configuration))["host_public_ip"]
  lxd_br0_network_part          = yamldecode(file(local.host_configuration))["lxd_br0_network_part"]
  lxd_host_network_part         = yamldecode(file(local.host_configuration))["lxd_host_network_part"]
}

# Common to almost all projects - service proxy module
# Remove if not needed for this project
# Variables from ryo-service-proxy module remote state
data "terraform_remote_state" "ryo-service-proxy" {
  backend = "local"
  config = {
    path = join("", ["${abspath(path.root)}/../../ryo-service-proxy/module-deployment/terraform.tfstate.d/", var.host_id, "/terraform.tfstate"])
  }
}

locals {
  consul_ip_address  = data.terraform_remote_state.ryo-service-proxy.outputs.consul_ip_address
}
