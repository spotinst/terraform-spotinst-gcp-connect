locals {
  cmd             = "${path.module}/scripts/spot-account"
  name            = var.name == null ? var.project : var.name
  account_id      = data.external.account.result["account_id"]
  organization_id = data.external.account.result["organization_id"]
  spotinst_token  = var.debug == true ? nonsensitive(var.spotinst_token) : var.spotinst_token
  private_key     = nonsensitive(google_service_account_key.key.private_key)
}

resource "random_id" "role" {
  byte_length = 8
}