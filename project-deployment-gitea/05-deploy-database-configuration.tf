# SPDX-FileCopyrightText: 2022 Wilfred Nicoll <xyzroller@rollyourown.xyz>
# SPDX-License-Identifier: GPL-3.0-or-later

# Deploy synapse database
#########################

module "deploy-synapse-database-and-user" {
  source = "../../ryo-postgres/module-deployment/modules/deploy-postgres-db-and-user"

  postgres_db_name           = "synapse"
  postgres_db_owner          = "synapse_user"
  postgres_db_owner_password = local.postgres_synapse_user_password
  postgres_db_template       = "template0"
  postgres_db_encoding       = "UTF8"
  postgres_db_lc_collate     = "C"
  postgres_db_lc_type        = "C"
}
