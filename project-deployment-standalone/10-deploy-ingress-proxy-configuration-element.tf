# Deploy Ingress Proxy configuration for element
################################################

module "deploy-matrix-ingress-proxy-backend-services-for-element" {

  depends_on = [ lxd_container.element ]

  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-backend-services"

  non_ssl_backend_services = [ "element" ]
}

module "deploy-matrix-ingress-proxy-acl-configuration-for-element" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-matrix-ingress-proxy-backend-services-for-element ]

  ingress-proxy_host_only_acls = {
    host-element = {host = join("", [ "element.", local.project_domain_name])}
  }
}

module "deploy-matrix-ingress-proxy-backend-configuration-for-element" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-ingress-proxy-configuration"

  depends_on = [ module.deploy-matrix-ingress-proxy-acl-configuration-for-element ]

  ingress-proxy_acl_use-backends = {
    host-element = {backend_service = "element"}
  }
}
