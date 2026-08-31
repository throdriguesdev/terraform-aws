include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules/ec2-game-server"
}

inputs = {
  name           = values.name
  instance_type  = try(values.instance_type, "c6a.xlarge")
  key_name       = values.key_name
  volume_size    = try(values.volume_size, 30)
  server_name    = try(values.server_name, "pzserver")
  admin_password = values.admin_password
}
