output "spot_account_id" {
    description = "spot account_id"
    value       = data.external.account.result["account_id"]
}

output "private_key" {
    description = "private key for service account"
    value = google_service_account_key.key.private_key
}