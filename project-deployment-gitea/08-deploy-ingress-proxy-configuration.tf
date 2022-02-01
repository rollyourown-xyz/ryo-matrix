# Deploy Ingress Proxy configuration for synapse and element
############################################################

module "deploy-matrix-ingress-proxy-backend-services" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"

  depends_on = [ lxd_container.synapse, lxd_container.element ]

  non_ssl_backend_services = [ "synapse", "element" ]
}

module "deploy-matrix-ingress-proxy-configuration" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-matrix-ingress-proxy-backend-services ]

  ingress-proxy_path_only_acls = {
    path-synapse-admin  = {path = "/_synapse/admin"}
    path-synapse-client = {path = "/_synapse/client"}
    path-matrix         = {path = "/_matrix"}
  }

  ingress-proxy_host_only_acls = {
    host-element = {host = join("", [ "element.", local.project_domain_name])}
  }

  ingress-proxy_acl_denys = [ "path-synapse-admin" ]

  ingress-proxy_acl_use-backends = {
    path-synapse-client = {backend_service = "synapse"},
    path-matrix         = {backend_service = "synapse"},
    host-element        = {backend_service = "element"}
  }
}
