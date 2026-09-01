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
    private_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002", "subnet-00000000000000003"]
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
  source = "${get_repo_root()}/catalog/modules/eks"
}

inputs = {
  cluster_name              = values.cluster_name
  kubernetes_version        = try(values.kubernetes_version, "1.32")
  region                    = local.region
  vpc_id                    = dependency.vpc.outputs.vpc_id
  subnet_ids                = dependency.vpc.outputs.private_subnet_ids
  instance_types            = try(values.instance_types, ["t3.medium"])
  node_min_size             = try(values.node_min_size, 1)
  node_max_size             = try(values.node_max_size, 3)
  node_desired_size         = try(values.node_desired_size, 2)
  ami_type                  = try(values.ami_type, "AL2023_x86_64_STANDARD")
  node_max_unavailable      = try(values.node_max_unavailable, 1)
  kms_key_arn               = dependency.kms.outputs.key_arn
  enabled_cluster_log_types = try(values.enabled_cluster_log_types, [])
  public_access_cidrs       = try(values.public_access_cidrs, [])
  authentication_mode       = try(values.authentication_mode, "API_AND_CONFIG_MAP")
  capacity_type             = try(values.capacity_type, "ON_DEMAND")
  enable_ebs_csi            = try(values.enable_ebs_csi, true)
}
