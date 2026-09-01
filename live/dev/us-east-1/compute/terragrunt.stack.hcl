locals {
  units_path = "${get_repo_root()}/catalog/units"
}

unit "eks" {
  source = "${local.units_path}/eks"
  path   = "eks"
  values = {
    cluster_name       = "practice-dev"
    kubernetes_version = "1.32"
    instance_types     = ["t3.small"]
    capacity_type      = "SPOT"
    node_min_size      = 1
    node_max_size      = 3
    node_desired_size  = 2

    # enabled_cluster_log_types = ["api", "audit", "authenticator"]  # CloudWatch /aws/eks/practice-dev/cluster

    # Restrict public API endpoint to your IP — replace or set to ["0.0.0.0/0"] to open
    # public_access_cidrs = ["YOUR_IP/32"]

    # API_AND_CONFIG_MAP keeps the aws-auth ConfigMap working alongside access entries
    authentication_mode = "API_AND_CONFIG_MAP"
  }
}

unit "eks-addons" {
  source = "${local.units_path}/eks-addons"
  path   = "eks-addons"
  values = {
    dns_zone = "lab.trdevops.com.br"

    enable_aws_load_balancer_controller = true
    enable_cert_manager                 = true
    enable_external_dns                 = true
    enable_external_secrets             = true
  }
}
