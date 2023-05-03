include {
  path = find_in_parent_folders()
}

terraform {
  source       = "git::https://github.com/terraform-google-modules/terraform-google-sql-db.git"
}

