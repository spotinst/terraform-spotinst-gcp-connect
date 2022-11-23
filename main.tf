# Call Spot API to create the Spot Account
resource "null_resource" "account" {
    count           = var.import_existing ? 0 : 1
    triggers = {
        cmd         = "${path.module}/scripts/spot-account"
        name        = local.name
        token       = local.spotinst_token
    }
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command     = "${self.triggers.cmd} create '${self.triggers.name}' --token=${self.triggers.token}"
    }
    provisioner "local-exec" {
        when        = destroy
        interpreter = ["/bin/bash", "-c"]
        command     = <<-EOT
            ID=$(${self.triggers.cmd} get --filter=name=${self.triggers.name} --attr=account_id --token=${self.triggers.token}) &&\
            ${self.triggers.cmd} delete "$ID" --token=${self.triggers.token}
        EOT
    }
}

resource "null_resource" "account_import_deletion" {
    count           = var.import_existing ? 1 : 0
    triggers = {
        cmd         = "${path.module}/scripts/spot-account"
        name        = local.name
        token       = local.spotinst_token
    }
    provisioner "local-exec" {
        when        = destroy
        interpreter = ["/bin/bash", "-c"]
        command     = <<-EOT
            ID=$(${self.triggers.cmd} get --filter=name=${self.triggers.name} --attr=account_id --token=${self.triggers.token}) &&\
            ${self.triggers.cmd} delete "$ID" --token=${self.triggers.token}
        EOT
    }
}

## Resources
resource "google_project_iam_custom_role" "SpotRole" {
    role_id     = var.role_id == null ? "SpotRole${replace(local.account_id,"-","")}" : var.role_id
    title       = var.role_title == null ? "SpotRole${replace(local.account_id,"-","")}" : var.role_title
    description = var.role_description
    project     = var.project
    permissions = var.role_permissions
}


resource "google_service_account" "spotserviceaccount" {
    provisioner "local-exec" {
        # Without this set-cloud-credentials fails
        command = "sleep 10"
    }
    account_id      = var.service_account_id == null ? "spot-${local.organization_id}-${local.account_id}" : var.service_account_id
    display_name    = var.service_account_display_name == null ? "spot-${local.organization_id}-${local.account_id}" : var.service_account_display_name
    description     = var.service_account_description
    project         = var.project
}


resource "google_service_account_key" "key" {
    service_account_id = google_service_account.spotserviceaccount.name
}


resource "google_project_iam_binding" "spot-account-iam" {
    project = var.project
    role    = google_project_iam_custom_role.SpotRole.name
    members = [
        google_service_account.spotserviceaccount.member
    ]
}


resource "google_project_iam_binding" "service-account-user-iam" {
    project = var.project
    role    = "roles/iam.serviceAccountUser"
    members = [
        google_service_account.spotserviceaccount.member
    ]
}

# Link the service account to the Spot Account
resource "null_resource" "account_association" {
    depends_on = [google_project_iam_binding.spot-account-iam]
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} set-cloud-credentials ${local.account_id} ${local.private_key} --token=${local.spotinst_token}"
    } 
}