include {
  path = find_in_parent_folders()
}


terraform {
  source       = "git::https://github.com/terraform-google-modules/google-external-address.git"
}

inputs = {
  project_id = "test-project"
  address_type = "EXTERNAL"
  names = [
    "nat-ip-01"
    
  ]

}
