locals {
  units_path = "${get_repo_root()}/catalog/units"
}

unit "kms" {
  source = "${local.units_path}/kms"
  path   = "kms"
  values = {
    alias = "practice-dev"
  }
}

unit "budget" {
  source = "${local.units_path}/budget"
  path   = "budget"
  values = {
    limit_amount       = "100"
    notification_email = get_env("TF_VAR_notification_email", "")
    thresholds         = [25, 50, 75, 100]
  }
}
