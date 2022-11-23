#Call the module to create a Spot account and link project
module "spot-gcp-connect" {
    source  = "spotinst/gcp-connect/spotinst"
    spotinst_token = "Redacted"

    # (Optional) Provide the name of the existing Spot Account, if omitted the project id will be used
    name = "project1"

    # GCP Project you would like to connect to Spot
    project = "project1"

    #flag to prevent creation of new account and import it
    import_existing = true

}

output "spot_account_id" {
    value = module.spot-gcp-connect.spot_account_id
}