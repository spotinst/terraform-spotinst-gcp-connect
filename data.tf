# Retrieve the Spot Account ID Information
data "external" "account" {
  depends_on = [null_resource.account]
  program = [
    local.cmd,
    "get",
    "--filter=name=${var.project}",
    "--token=${var.spotinst_token}"
  ]
}
