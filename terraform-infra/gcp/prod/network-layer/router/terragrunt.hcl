include {
  path = find_in_parent_folders()
}


terraform {
  source = "git::https://github.com/terraform-google-modules/terraform-google-cloud-router"
}


dependency "vpc" {
  config_path = "../vpc/"
  mock_outputs = {
    network_name = "dummy-network-name2"

  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  project = "test-project"
  network = dependency.vpc.outputs.network_name
  name = "test-router"
  region = "asia-south1"
}
