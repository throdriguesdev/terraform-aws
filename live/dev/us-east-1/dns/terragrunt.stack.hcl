locals {
  units_path = "${get_repo_root()}/catalog/units"
}

unit "zone" {
  source = "${local.units_path}/route53-zone"
  path   = "zone"
  values = {
    zone_name = "lab.trdevops.com.br"
    comment   = "Practice lab — delegate NS records from Vercel"
  }
}
