#Call the module to create a Spot account and link project
module "spotinst-gcp-connect-project1" {
    source  = "spotinst/gcp-connect/spotinst"
    project = "project1"
}

output "spot_account_id" {
    value = module.spotinst-gcp-connect-project1.spot_account_id
}