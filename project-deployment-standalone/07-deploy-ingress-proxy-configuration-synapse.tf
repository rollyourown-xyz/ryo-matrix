# Deploy Ingress Proxy configuration for synapse
################################################

module "deploy-matrix-ingress-proxy-backend-services-for-synapse" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"

  depends_on = [ lxd_container.synapse ]

  non_ssl_backend_services = [ "synapse" ]
}

module "deploy-matrix-ingress-proxy-acl-configuration-for-synapse" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-matrix-ingress-proxy-backend-services-for-synapse ]

  ingress-proxy_path_only_acls = {
    path-synapse-admin  = {path = "/_synapse/admin"}
    path-synapse-client = {path = "/_synapse/client"}
    path-matrix         = {path = "/_matrix"}
  }
}

module "deploy-matrix-ingress-proxy-deny-configuration-for-synapse" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-matrix-ingress-proxy-acl-configuration-for-synapse ]

  ingress-proxy_acl_denys = [ "path-synapse-admin" ]
}

module "deploy-matrix-ingress-proxy-backend-configuration-for-synapse" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-matrix-ingress-proxy-acl-configuration-for-synapse ]

  ingress-proxy_acl_use-backends = {
    path-synapse-client = {backend_service = "synapse"},
    path-matrix         = {backend_service = "synapse"}
  }
}
