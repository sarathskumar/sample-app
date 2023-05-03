# sample-app
Repository for creating infrastructure using terraform with terragrunt as a wrapper and deploy a high availablity nginx application using helm

# Infra-Creation

   # Pre-requisite

   Install terraform latest verison
   Install terragrunt

   # Service account key creation in GCP for creating these resources. Give only minimal permission for creating these resources
   
   https://cloud.google.com/iam/docs/keys-create-delete

   # Setup Enviornment variables 

   export GOOGLE_APPLICATION_CREDENTIALS = /Users/service-account-key.json 

   # Description

    Creating the Infrastructure using terraform and along with a wrapper terragrunt. We can create the whole cloud resources using at a single shot command. I am using here GCP as the cloud provider.

    As of now i am storing the statefile in local only. If we have a remote storage like GCS bucket or other cloud object storage we can use that as my statefile storage.

   # Directory-structure
     
     └── gcp
    ├── non-prod
    │   ├── app-layer
    │   │   ├── bastion-host
    │   │   │   └── terragrunt.hcl
    │   │   └── gke-applayer
    │   │       └── terragrunt.hcl
    │   ├── data-layer
    │   │   └── cloud-sql
    │   │       └── terragrunt.hcl
    │   ├── network-layer
    │   │   ├── address
    │   │   │   └── terragrunt.hcl
    │   │   ├── nat
    │   │   │   └── terragrunt.hcl
    │   │   ├── router
    │   │   │   └── terragrunt.hcl
    │   │   ├── subnets
    │   │   │   ├── subnet1-app
    │   │   │   │   └── terragrunt.hcl
    │   │   │   └── subnet2-data
    │   │   │       └── terragrunt.hcl
    │   │   └── vpc
    │   │       └── terragrunt.hcl
    │   └── terragrunt.hcl
    ├── prod
    │   ├── app-layer
    │   │   ├── bastion-host
    │   │   │   └── terragrunt.hcl
    │   │   └── gke-applayer
    │   │       └── terragrunt.hcl
    │   ├── data-layer
    │   │   └── cloud-sql
    │   │       └── terragrunt.hcl
    │   └── network-layer
    │       ├── address
    │       │   └── terragrunt.hcl
    │       ├── nat
    │       │   └── terragrunt.hcl
    │       ├── router
    │       │   └── terragrunt.hcl
    │       ├── subnets
    │       │   ├── subnet1-app
    │       │   │   └── terragrunt.hcl
    │       │   └── subnet2-data
    │       │       └── terragrunt.hcl
    │       └── vpc
    │           └── terragrunt.hcl
    └── terragrunt.hcl

Here i am using terraform modules for creating each resources so i can reuse it for different enviornment like non-prod, prod etc. 

NOTE:- I am only adding files in prod enviornment. non-prod is an dummy folder.




# Commands to play with infra

Clone this Repo
cd sample-app/terraform-infra

      Run this below command for plan 

                                         terragrunt run-all plan
      
      This command will plan whatever resources if you want to create in multiple enviornments. Otherwise if you want to run specific enviornment you can change directory into the enviornment folder and then run this command

      
      Run this below command for apply

                                         terragrunt run-all apply

Advanced command options please checkout here
https://terragrunt.gruntwork.io/docs/reference/cli-options/


# Future scope for create infrastrcutre

If anyone wants create a cloud resources they want to raise a PR in the source code repository (github). Then they can run the plan for resources using github comment. Then we can integrates the InfraCost into that workflow then we should know about the cost for the specific configuration of that resources. We can integrates the IAC code scanning also here using checkov. Then the codeowner review the IAC code and review the plan then it automatically apply the specific cloud resources.

We can achieve this using some tools like atlantis, workflows.



# Application Deployment

    Deploying a sample nginx application using helm.

  # Pre-requisite

    Install helm package manager

  # Configure the kubeconfig file

   Generate a kubeconfig file for your kubernetes cluster to apply the chart.

  # Description

   Here i am deploying an nginx sample applciation. For high availability for this app i am creating a HPA(horizontal pod autoscaler). Creating an endpoint with kubernetes ingress access this application internally.

  # Directory-structure

    ├── nginx-ha-app-helm-chart
    │   ├── Chart.yaml
    │   ├── subchart-reference.yaml
    │   ├── templates
    │   │   ├── NOTES.txt
    │   │   ├── _helpers.tpl
    │   │   ├── deployment.yaml
    │   │   ├── hpa.yaml
    │   │   ├── ingress.yaml
    │   │   ├── service.yaml
    │   │   ├── serviceaccount.yaml
    │   │   └── tests
    │   │       └── test-connection.yaml
    │   └── values-reference.yaml
    └── nginx-ha-app-helm-values
        ├── Chart.yaml
        └── gcp
            ├── non-prod
            │   └── values.yaml
            └── prod
                └── values.yaml


  # PLAN OF ACTION

    Create 2 seperate directory for helm chart and helm vaules files. Then push the helm chart to a artifactory repository manager here i am using nexus. So every time the templates or anything they want to change and push the chart. For the deployment dev can use the helm values folders. There also i am segregated with enviornment specific so if anyone wants to apply for non prod only they can use the non-prod values.yaml.

    Here i am using helm dependency so i first we need to run the command helm dependecy build and then validate.


  # Future Scope for this structure


    Integrates this with the GitOps model.Create 2 seperate repository for helm chart and the helm values folder. Then craete workflow when a changes come to the master branch then run a workflow for push the repository into the nexus and promote the particular image deploy to the specific enviornment. This setup we can implement into CD pipelines.



    

         


