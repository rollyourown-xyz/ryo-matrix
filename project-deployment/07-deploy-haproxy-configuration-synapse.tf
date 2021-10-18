# Deploy HAProxy configuration for synapse
##########################################

module "deploy-matrix-haproxy-backend-services-for-synapse" {

  depends_on = [ lxd_container.synapse ]

  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-backend-services"

  non_ssl_backend_services = [ "synapse" ]
}

module "deploy-matrix-haproxy-acl-configuration-for-synapse" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-matrix-haproxy-backend-services-for-synapse ]

  haproxy_path_only_acls = {
    path-synapse-admin  = {path = "/_synapse/admin"}
    path-synapse-client = {path = "/_synapse/client"}
    path-matrix         = {path = "/_matrix"}
  }
}

module "deploy-matrix-haproxy-deny-configuration-for-synapse" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-matrix-haproxy-acl-configuration-for-synapse ]

  haproxy_acl_denys = [ "path-synapse-admin" ]
}

module "deploy-matrix-haproxy-backend-configuration-for-synapse" {
  source = "../../ryo-service-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-matrix-haproxy-acl-configuration-for-synapse ]

  haproxy_acl_use-backends = {
    path-synapse-client = {backend_service = "synapse"},
    path-matrix         = {backend_service = "synapse"}
  }
}
