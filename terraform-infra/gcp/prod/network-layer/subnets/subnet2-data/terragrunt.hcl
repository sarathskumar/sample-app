include {
  path = find_in_parent_folders()
}


terraform {
    source = "git::https://github.com/terraform-google-modules/terraform-google-network.git//modules/subnets"
}


dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    network_name = "dummy-network-name2"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project_id = 
  network_name = dependency.vpc.outputs.network_name
  subnets = [
      {
          subnet_name           = "datalayer-01"
          subnet_ip             = "10.82.10.0"
          subnet_region         = "asia-south1"
          subnet_private_access = "true"
          description           = "The subnet for data layer"
      }

  ]
}
