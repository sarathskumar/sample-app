include {
  path = find_in_parent_folders()
}

terraform {
  source       = "git::https://github.com/terraform-google-modules/terraform-google-vm.git//modules/compute_instance"
}

locals {
  env = "release"
  resource_labels = {"tier": "t1", "function": "bastion", "pod": local.common_vars.pod, "role": "bastion", "subpod": local.common_vars.subpod, "env": local.env}
  host_project = format("%s-%s-host", local.common_vars.nomenclature, local.env)
  service_project = format("%s-%s-applayer", local.common_vars.nomenclature, local.env)
}

dependency "vpc_network" {
  config_path = "../../prod/network-layer/vpc/"
  mock_outputs = {
    network_id = "projects/elements-release/global/networks/elements-release"

  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "nodepool_subnet" {
  config_path = "../../network-layer/subnets/subnet1-app/"
  mock_outputs = {
    subnets_names = ["sample-subnet-name"]
    subnets_secondary_ranges = [
      []
    ]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  vm_name = format("%s-%s-bastion", local.common_vars.nomenclature, local.env)
  machine_type = "e2-standard-2"
  min_cpu_platform = "Intel Skylake"
  zone = "asia-south1-c"
  enable_shielded_vm = true
  project_id = "test-project"
  subnetwork_project_id = "test-project"
  network_name = dependency.vpc_network.outputs.network_name # VPC network name
  subnetwork_name = "${element(split("/", keys(dependency.nodepool_subnet.outputs.subnets)[0]), 1)}" # Subnet name
  
  metadata = {
    VmDnsSetting="GlobalDefault"
    deletion-protection = true
    block-projectssh-keys = true
  }

  vm_tags = [
    "allow-bastion"
  ]

  boot_disk = {
    auto_delete   = false,
    device_name   = "dev1",
    mode          = "READ_WRITE",
    image         = local.common_vars.vm_image
    image_family  = "ubuntu",
    image_project = "mgmt-infra-mgmt-a452",
    disk_size     = 50,
    disk_type     = "pd-ssd",
  }

  network_interfaces = [{
    network            = dependency.vpc_network.outputs.network_name,
    subnetwork         = "${element(split("/", keys(dependency.nodepool_subnet.outputs.subnets)[0]), 1)}",
    subnetwork_project = dependency.host_project.outputs.project_id,
    network_ip         = "",
    access_config = []
  }]

  shielded_instance_config = {
    enable_secure_boot = true
    enable_vtpm = true
    enable_integrity_monitoring = true
  }

  /*
    Final disk name generated is -
    <disk_name>-<vm_name>-<key> in below map
  */
  attached_disks = {

  }

}
