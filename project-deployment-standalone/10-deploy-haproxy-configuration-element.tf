# Deploy HAProxy configuration for element
##########################################

module "deploy-matrix-haproxy-backend-services-for-element" {

  depends_on = [ lxd_container.element ]

  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-haproxy-backend-services"

  non_ssl_backend_services = [ "element" ]
}

module "deploy-matrix-haproxy-acl-configuration-for-element" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-matrix-haproxy-backend-services-for-element ]

  haproxy_host_only_acls = {
    host-element = {host = join("", [ "element.", local.project_domain_name])}
  }
}

module "deploy-matrix-haproxy-backend-configuration-for-element" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-haproxy-configuration"

  depends_on = [ module.deploy-matrix-haproxy-acl-configuration-for-element ]

  haproxy_acl_use-backends = {
    host-element = {backend_service = "element"}
  }
}
