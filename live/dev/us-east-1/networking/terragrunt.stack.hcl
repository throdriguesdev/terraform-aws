locals {
  units_path = "${get_repo_root()}/catalog/units"
}

unit "vpc" {
  source = "${local.units_path}/vpc"
  path   = "vpc"
  values = {
    name = "main-dev"
    cidr = "10.0.0.0/16"
    azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]

    # /20 = 4,094 IPs per subnet
    public_subnets   = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
    private_subnets  = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
    database_subnets = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]

    enable_nat = true
    single_nat = true

    public_subnet_tags = {
      "kubernetes.io/role/elb" = "1"
    }
    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = "1"
    }
  }
}
