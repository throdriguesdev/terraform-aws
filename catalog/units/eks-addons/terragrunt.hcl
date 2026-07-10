include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment = local.env_vars.locals.environment
  region      = local.region_vars.locals.region
  aws_profile = get_env("TF_VAR_aws_profile", "default")
}

dependency "eks" {
  config_path = "${get_repo_root()}/live/${local.environment}/${local.region}/compute/.terragrunt-stack/eks"

  mock_outputs = {
    cluster_name      = "mock-cluster"
    oidc_provider_arn = "arn:aws:iam::000000000000:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/MOCK"
    oidc_issuer_url   = "https://oidc.eks.us-east-1.amazonaws.com/id/MOCK"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "vpc" {
  config_path = "${get_repo_root()}/live/${local.environment}/${local.region}/networking/.terragrunt-stack/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    data "aws_eks_cluster" "this" {
      name = var.cluster_name
    }

    provider "helm" {
      kubernetes {
        host                   = data.aws_eks_cluster.this.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--region", "${local.region}", "--profile", "${local.aws_profile}"]
        }
      }
    }
  EOF
}

terraform {
  source = "${get_repo_root()}/catalog/modules/eks-addons"
}

inputs = {
  cluster_name      = dependency.eks.outputs.cluster_name
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  oidc_issuer_url   = dependency.eks.outputs.oidc_issuer_url
  vpc_id            = dependency.vpc.outputs.vpc_id
  region            = local.region
  dns_zone          = try(values.dns_zone, "")

  enable_aws_load_balancer_controller = try(values.enable_aws_load_balancer_controller, true)
  enable_cert_manager                 = try(values.enable_cert_manager, true)
  enable_external_dns                 = try(values.enable_external_dns, true)
  enable_external_secrets             = try(values.enable_external_secrets, true)

  lbc_chart_version              = try(values.lbc_chart_version, "1.8.1")
  cert_manager_chart_version     = try(values.cert_manager_chart_version, "v1.14.5")
  external_dns_chart_version     = try(values.external_dns_chart_version, "1.14.4")
  external_secrets_chart_version = try(values.external_secrets_chart_version, "0.9.11")
}
