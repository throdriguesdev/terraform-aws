include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules/route53-zone"
}

inputs = {
  zone_name      = values.zone_name
  comment        = try(values.comment, "")
  private_vpc_id = try(values.private_vpc_id, null)
}
