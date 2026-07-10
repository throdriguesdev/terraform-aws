include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.locals.environment
  region      = local.region_vars.locals.region
}

dependency "vpc" {
  config_path = "${get_repo_root()}/live/${local.environment}/${local.region}/networking/.terragrunt-stack/vpc"

  mock_outputs = {
    vpc_id             = "vpc-00000000000000000"
    vpc_cidr           = "10.0.0.0/16"
    database_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002", "subnet-00000000000000003"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "kms" {
  config_path = "${get_repo_root()}/live/${local.environment}/${local.region}/foundation/.terragrunt-stack/kms"

  mock_outputs = {
    key_arn = "arn:aws:kms:us-east-1:000000000000:key/00000000-0000-0000-0000-000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "${get_repo_root()}/catalog/modules/rds-postgres"
}

inputs = {
  identifier                   = values.identifier
  database_name                = try(values.database_name, "app")
  master_username              = try(values.master_username, "postgres")
  engine_version               = try(values.engine_version, "16.6")
  instance_class               = try(values.instance_class, "db.t3.micro")
  allocated_storage            = try(values.allocated_storage, 20)
  max_allocated_storage        = try(values.max_allocated_storage, 100)
  vpc_id                       = dependency.vpc.outputs.vpc_id
  subnet_ids                   = dependency.vpc.outputs.database_subnet_ids
  allowed_cidr_blocks          = [dependency.vpc.outputs.vpc_cidr]
  kms_key_arn                  = dependency.kms.outputs.key_arn
  multi_az                     = try(values.multi_az, false)
  backup_retention_period      = try(values.backup_retention_period, 1)
  skip_final_snapshot          = try(values.skip_final_snapshot, true)
  deletion_protection          = try(values.deletion_protection, false)
  performance_insights_enabled = try(values.performance_insights_enabled, true)
}
