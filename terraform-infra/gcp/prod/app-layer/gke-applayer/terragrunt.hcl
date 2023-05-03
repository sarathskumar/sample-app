include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/terraform-google-modules/terraform-google-kubernetes-engine.git//modules/beta-private-cluster?ref=v20.0.1"
}

locals {
  env = "release"
  cluster = "cluster"
  common_vars = yamldecode(file(find_in_parent_folders("common.yaml")))
  resource_labels = {"tier": "t1", "function": "gke", "pod": local.common_vars.pod, "role": "nodepool", "subpod": local.common_vars.subpod, "env": local.env}
  host_project = format("%s-%s-host", local.common_vars.nomenclature, local.env)
  service_project = format("%s-%s-applayer", local.common_vars.nomenclature, local.env)
  nodepool_labels = {"name": "elements-${local.env}-nodepool", "region": local.common_vars.region, "cloud": "gcp", "datacenter": "primary", "role": "nodepool", "cluster": format("%s-%s-%s", local.common_vars.nomenclature,local.env, local.cluster) }
  controlplane_labels = {"role": "controlplane", "cluster": format("%s-%s-%s", local.common_vars.nomenclature,local.env, local.cluster)}
  node_pool_01 = "sts-nodepool-01"
  node_pool_02 = "spot-nodepool-01"
}




dependency "vpc_network" {
  config_path = "../../network-layer/vpc/"
  mock_outputs = {
    network_id = "projects/elements-release/global/networks/elements-release"

  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "nodepool_subnet" {
  config_path = "../../network-layer/subnets/subnet1-app/"
  mock_outputs = {
    subnets_names = ["sample-subnet-name"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}



dependency "bastion" {
  config_path = "../bastion-host/"
  mock_outputs = {
    service_account_email = "example@developer.gserviceaccount.com"
  }
}

inputs = {
  project_id = "test-project"
  name = "applayer-cluster-01"
  zones  = ["asia-south1-a", "asia-south1-b", "asia-south1-c"]
  master_ipv4_cidr_block = "172.16.0.2"
  network = dependency.vpc_network.outputs.network_name
  network_project_id = "test-project"
  subnetwork = "${element(split("/", keys(dependency.nodepool_subnet.outputs.subnets)[0]), 1)}"
  ip_range_pods = format("%s-%s-applayer-gkepods", local.common_vars.nomenclature,local.env)  #"elements-release-applayer-gkepods" 
  ip_range_services = format("%s-%s-applayer-gkeservice", local.common_vars.nomenclature,local.env)
  http_load_balancing = true
  network_policy       = false
  network_policy_provider    = "PROVIDER_UNSPECIFIED"
  datapath_provider = "ADVANCED_DATAPATH"
  enable_network_egress_export = true
  master_authorized_networks = [{
    cidr_block   = format("%s/32", dependency.bastion.outputs.internal_ip[0])
    display_name = "bastion-host"
  }]
  enable_resource_consumption_export = true
  enable_shielded_nodes      = true
  grant_registry_access = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  enable_private_endpoint    = true
  enable_private_nodes       = true
  default_max_pods_per_node  = "50"
  
  enable_binary_authorization = false  ## need to test this out


  remove_default_node_pool = true
  master_global_access_enabled = true
  release_channel       = "UNSPECIFIED"
  kubernetes_version = "1.25.6-gke.200"
  notification_config_topic = "prod-gkenotification"      
  cluster_autoscaling = {
    enabled             = false
    max_cpu_cores       = 0
    min_cpu_cores       = 0
    max_memory_gb       = 0
    min_memory_gb       = 0
    gpu_resources       = []
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
  }
  maintenance_start_time = "2022-04-01T01:00:00Z"
  maintenance_end_time = "2022-04-02T01:00:00Z"
  maintenance_recurrence ="FREQ=WEEKLY;BYDAY=FR"


  node_pools = [
    {
      name                      = local.node_pool_01
      machine_type              = "custom-16-32768"
      node_locations            = "asia-south1-a,asia-south1-b,asia-south1-c"
      min_count                 = 1
      max_count                 = 2
      local_ssd_count           = 0
      spot                      = false
      local_ssd_ephemeral_count = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "UBUNTU_CONTAINERD"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "test-service-account"
      preemptible               = false
      initial_node_count        = 1
      max_pods_per_node         = 40
      enable_secure_boot = true
    },
    {
      name                      = local.node_pool_02
      machine_type              = "custom-16-32768"
      node_locations            = "asia-south1-a,asia-south1-b,asia-south1-c"
      min_count                 = 1
      max_count                 = 2
      autoscaling	        = false
      local_ssd_count           = 0
      spot                      = false
      local_ssd_ephemeral_count = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "UBUNTU_CONTAINERD"
      auto_repair               = true
      auto_upgrade              = true
      service_account           = "test-service-account"
      preemptible               = false
      initial_node_count        = 1
      max_pods_per_node         = 40
      enable_secure_boot = true
    }
  ]
  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform" 
    ]
    
    "${local.node_pool_01}" = []
    "${local.node_pool_02}" = []
  }

  node_pools_labels = { all = merge("${local.nodepool_labels}", "${local.resource_labels}"), "${local.node_pool_01}" = {"pool-type": "${local.node_pool_01}", "${local.node_pool_01}": true}, "${local.node_pool_02}" = {"pool-type": "${local.node_pool_02}", "${local.node_pool_02}": true}}

  node_pools_metadata = { all = {}, "${local.node_pool_01}" = {node-pool-metadata-custom-value = "${local.node_pool_01}"}, "${local.node_pool_01}" = {node-pool-metadata-custom-value = "${local.node_pool_01}"}, "${local.node_pool_02}" = {node-pool-metadata-custom-value = "${local.node_pool_02}"}, "${local.node_pool_02}" = {node-pool-metadata-custom-value = "${local.node_pool_02}"}}

  node_pools_taints = { all = []}
  node_pools_tags ={ all = [], "${local.node_pool_01}" = ["${local.node_pool_01}"], "${local.node_pool_02}" = ["${local.node_pool_02}"]}
}
