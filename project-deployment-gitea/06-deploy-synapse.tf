# Deploy synapse homeserver
###########################

resource "lxd_container" "synapse" {

  depends_on = [ module.deploy-synapse-database-and-user ]

  remote     = var.host_id
  name       = "synapse"
  image      = join("-", [ local.project_id, "synapse", var.image_version ])
  profiles   = ["default"]
  
  config = { 
    "security.privileged": "false"
    "user.user-data" = file("cloud-init/cloud-init-synapse.yml")
  }
  
  # Provide eth0 interface with dynamic IP address
  device {
    name = "eth0"
    type = "nic"

    properties = {
      name           = "eth0"
      network        = var.host_id
    }
  }
  
  # Mount container directory for persistent storage for synapse configuration
  device {
    name = "synapse-config"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/synapse/config" ])
      path     = "/etc/matrix-synapse"
      readonly = "false"
      shift    = "true"
    }
  }
  
  # Mount container directory for persistent storage for synapse data
  device {
    name = "synapse-data"
    type = "disk"
    
    properties = {
      source   = join("", [ "/var/containers/", local.project_id, "/synapse/data" ])
      path     = "/var/lib/matrix-synapse"
      readonly = "false"
      shift    = "true"
    }
  } 
}
