include {
  path = find_in_parent_folders()
}


terraform {
  source = "git::https://github.com/terraform-google-modules/terraform-google-cloud-nat.git"
}


dependency "address" {
    config_path = "../address"
    mock_outputs = {
         names = ["dummy-external-ip-address-1"]
    }
    mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "router" {
  config_path = "../router"
  mock_outputs = {
    router_name = "dummy-router"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "subnet1_applayer" {
  config_path = "../subnets/subnet1-app"
  mock_outputs = {
      subnets_names = ["test-subnet1", "test-subnet2"]
      subnets_ips = ["142.34.56.7","1,2,3,4"]
      secondary_ip_range_names = [["123.43.5.8"],[]]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "subnet2_datalayer" {
  config_path = "../subnets/subnet2-data"
  mock_outputs = {
      subnets_names = ["test-subnet1", "test-subnet2"]
      subnets_ips = ["142.34.56.7","1,2,3,4"]
      secondary_ip_range_names = [["123.43.5.8"],[]]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  name = "test-nat"
  project_id = "test-project"
  router_name = dependency.router.outputs.router.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  min_ports_per_vm                   = 64
  icmp_idle_timeout_sec              = 15
  tcp_established_idle_timeout_sec   = 600
  tcp_transitory_idle_timeout_sec    = 15
  udp_idle_timeout_sec               = 15
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  log_config_enable                  = true
  nat_ips = [
    dependency.address.outputs.names[0]

  ]

  subnetworks = flatten([
      {
          name = "applayer-01"
          source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
          secondary_ip_range_names = []
          # Allowed values are: ALL_IP_RANGES (Primary + Secondary), PRIMARY_IP_RANGE
      },
      {
          name = "datalayer-01"
          source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
          secondary_ip_range_names = []
          # Allowed values are: ALL_IP_RANGES (Primary + Secondary), PRIMARY_IP_RANGE
      }
  ])
}
