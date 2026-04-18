include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules/kms"
}

inputs = {
  alias                   = values.alias
  deletion_window_in_days = try(values.deletion_window_in_days, 7)
}
