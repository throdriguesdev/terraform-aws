include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  environment = local.env_vars.locals.environment
}

terraform {
  source = "${get_repo_root()}/catalog/modules/budget"
}

inputs = {
  limit_amount       = values.limit_amount
  notification_email = values.notification_email
  thresholds         = try(values.thresholds, [25, 50, 75, 100])
  environment        = local.environment
}
