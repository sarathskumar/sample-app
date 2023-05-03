include {
  path = find_in_parent_folders()
}


terraform {
    source = "git::https://github.com/terraform-google-modules/terraform-google-network.git//modules/vpc"
    
}

inputs = {
  project_id = "test-project-id"
  network_name = "test-vpc"
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
  description  = "Host network"
  shared_vpc_host = "true"
  delete_default_internet_gateway_routes = "false"
  mtu = 1460
}

