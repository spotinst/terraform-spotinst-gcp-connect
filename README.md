# Connect GCP Project To Spot.io Terraform Module

## Introduction
The module will aid in automatically connecting your GCP project to Spot via terraform. This will also leverage a python script to create the Spot account within your Spot Organization and attach the GCP service account credential.

### Pre-Reqs
* Spot Organization Admin API token.
* Python 3 installed. 

## Usage
```hcl
#Call the spot module to create a Spot account and link project to the platform
module "spotinst-gcp-connect-project1" {
    source          = "spotinst/gcp-connect/spotinst"
    project         = "project1"
    spotinst_token  = "redacted"
}
output "spot_account_id" {
    value = module.gcp_connect_project1.spot_account_id
}
```

### Run
This terraform module will do the following:

On Apply:
* Create GCP Service Account
* Create GCP Service Account Key
* Create GCP Project Role
* Create Spot Account within Spot Organization
* Assign Project Role to Service Account
* Provide GCP Service Account Key to newly created Spot Account

On Destroy:
* Remove all above resources including deleting the Spot Account
