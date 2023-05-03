include {
  path = find_in_parent_folders()
}

terraform {
  source       = "git::https://github.com/terraform-google-modules/terraform-google-sql-db.git"
}


inputs = {
  project_id = "test-project"
  name                 = "test-db"
  random_instance_name = true
  database_version     = "MYSQL_5_7"
  region               = "us-central1"

  deletion_protection = false

  // Master configurations
  tier                            = "db-n1-standard-1"
  zone                            = "us-central1-c"
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  database_flags = [{ name = "long_query_time", value = 1 }]

  user_labels = {
    foo = "bar"
  }

  ip_configuration = {
    ipv4_enabled       = true
    require_ssl        = true
    private_network    = null
    allocated_ip_range = null
    authorized_networks = [
      {
        name  = "${var.project_id}-cidr"
        value = var.mysql_ha_external_ip_range
      },
    ]
  }

  backup_configuration = {
    enabled                        = true
    binary_log_enabled             = true
    start_time                     = "20:55"
    location                       = null
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }
}


