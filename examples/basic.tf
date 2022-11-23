#Call the module to create a Spot account and link project
module "spot-gcp-connect" {
    source  = "spotinst/gcp-connect/spotinst"
    spotinst_token = "Redacted"
    project = "project1"
}

output "spot_account_id" {
    value = module.spot-gcp-connect.spot_account_id
}