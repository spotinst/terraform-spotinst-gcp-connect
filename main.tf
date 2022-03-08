# Call Spot API to create the Spot Account
resource "null_resource" "account" {
    triggers = {
        cmd         = "${path.module}/scripts/spot-account"
        name        = var.project
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

## Resources
resource "google_project_iam_custom_role" "SpotRole" {
    role_id     = "SpotRole${replace(local.account_id,"-","")}"
    title       = "SpotRole${replace(local.account_id,"-","")}"
    description = var.role_description
    project     = var.project
    permissions = var.role_permissions
}


resource "google_service_account" "spotserviceaccount" {
    provisioner "local-exec" {
        # Without this set-cloud-credentials fails
        command = "sleep 10"
    }
    account_id      = "spot-${local.organization_id}-${local.account_id}"
    display_name    = "spot-${local.organization_id}-${local.account_id}"
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
        "serviceAccount:spot-${local.organization_id}-${local.account_id}@${var.project}.iam.gserviceaccount.com"
    ]
}


resource "google_project_iam_binding" "service-account-user-iam" {
    project = var.project
    role    = "roles/iam.serviceAccountUser"
    members = [
        "serviceAccount:spot-${local.organization_id}-${local.account_id}@${var.project}.iam.gserviceaccount.com"
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