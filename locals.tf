locals {
  cmd = "${path.module}/scripts/spot-account"
  account_id = data.external.account.result["account_id"]
  private_key = nonsensitive(google_service_account_key.key.private_key)
}

resource "random_id" "role" {
  byte_length = 8
}