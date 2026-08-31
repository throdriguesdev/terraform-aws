locals {
  units_path = "${get_repo_root()}/catalog/units"
}

unit "postgres" {
  source = "${local.units_path}/rds-postgres"
  path   = "postgres"
  values = {
    identifier      = "practice-dev"
    database_name   = "app"
    master_username = "postgres"
    engine_version  = "16.14"

    # db.t3.micro = free tier eligible, 20GB included
    instance_class        = "db.t3.micro"
    allocated_storage     = 20
    max_allocated_storage = 100

    multi_az                     = false
    backup_retention_period      = 1
    skip_final_snapshot          = true
    deletion_protection          = false
    performance_insights_enabled = true
  }
}
