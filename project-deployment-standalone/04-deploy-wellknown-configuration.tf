# Deploy wellknown configuration for the project
################################################

module "deploy-matrix-wellknown-configuration" {
  source = "../../ryo-wellknown/module-deployment/modules/deploy-wellknown-configuration"
  
  wellknown_json_rules = {
  
    matrix-client = {
      wellknown_domain       = local.project_domain_name,
      wellknown_path         = "/.well-known/matrix/client",
      wellknown_json_payload = join("", [ "'{ \"m.homeserver\": { \"base_url\": \"https://matrix.", local.project_domain_name, "\" }, \"m.identity_server\": { \"base_url\": \"https://matrix.org\" } }'" ])
    },

    matrix-server = {
      wellknown_domain       = local.project_domain_name,
      wellknown_path         = "/.well-known/matrix/server",
      wellknown_json_payload = join("", [ "'{ \"m.server\": \"", "matrix.", local.project_domain_name, ":443\" }'" ])
    }
  }
}
