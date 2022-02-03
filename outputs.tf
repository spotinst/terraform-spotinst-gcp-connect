output "spot_account_id" {
    description = "Spot Account ID"
    value       = local.account_id
}

output "private_key" {
    description = "private key for service account"
    value = google_service_account_key.key.private_key
    sensitive = true
}

output "spot_organization_id" {
    description = "Spot Organization ID"
    value = local.organization_id
}
