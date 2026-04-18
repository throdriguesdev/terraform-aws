include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/catalog/modules/vpc"
}

inputs = {
  name             = values.name
  cidr             = values.cidr
  azs              = values.azs
  public_subnets   = try(values.public_subnets, [])
  private_subnets  = try(values.private_subnets, [])
  database_subnets = try(values.database_subnets, [])
  enable_nat       = try(values.enable_nat, false)
  single_nat       = try(values.single_nat, true)

  public_subnet_tags   = try(values.public_subnet_tags, {})
  private_subnet_tags  = try(values.private_subnet_tags, {})
  database_subnet_tags = try(values.database_subnet_tags, {})
}
