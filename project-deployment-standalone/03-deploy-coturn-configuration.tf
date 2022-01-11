# Deploy coturn configuration for the project
###############################################

module "deploy-coturn-domain-configuration" {
  source = "../../ryo-coturn/module-deployment/modules/deploy-coturn-domain-configuration"
  
  coturn_domain             = local.project_coturn_domain_name
  coturn_domain_admin_email = local.project_admin_email
}
