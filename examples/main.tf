#Call the spot module to create a Spot account and link project
module "spot_account" {
    source = "../"

    # GCP Project you would like to connect to Spot
    project = "example"
}

output "spot_account_id" {
    value = module.spot_account.spot_account_id
}
