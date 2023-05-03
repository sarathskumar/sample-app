generate "gcs" {
  path      = "remote_state.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "local" {
    path = "terraform.tfstate"
}
EOF
}

terraform {
  extra_arguments "conditional_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]
  }
}







