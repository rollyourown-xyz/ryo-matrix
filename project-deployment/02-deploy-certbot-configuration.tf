# Deploy certbot configuration for project domains
##################################################

module "deploy-matrix-cert-domains" {
  source = "../../ryo-ingress-proxy/module-deployment/modules/deploy-cert-domains"

  certificate_domains = {
    domain_1 = {domain = local.project_domain_name, admin_email = local.project_admin_email},
    domain_2 = {domain = join("", [ "matrix.", local.project_domain_name]), admin_email = local.project_admin_email},
    domain_3 = {domain = join("", [ "element.", local.project_domain_name]), admin_email = local.project_admin_email}
  }
}
