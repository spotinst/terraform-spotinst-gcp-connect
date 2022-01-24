## Resources
resource "google_project_iam_custom_role" "SpotRole" {
  role_id     = "SpotRole${random_id.role.hex}"
  title       = "SpotRole${random_id.role.hex}"
  description = "Custom Role for Spot.io"
  permissions = ["compute.addresses.create", "compute.addresses.createInternal", "compute.addresses.delete", "compute.addresses.get", "compute.addresses.list", "compute.addresses.setLabels", "compute.addresses.useInternal", "compute.backendServices.get", "compute.backendServices.list", "compute.backendServices.update", "compute.diskTypes.get", "compute.diskTypes.list", "compute.disks.create", "compute.disks.createSnapshot", "compute.disks.delete", "compute.disks.get", "compute.disks.list", "compute.disks.update", "compute.disks.use", "compute.globalOperations.get", "compute.globalOperations.list", "compute.healthChecks.useReadOnly", "compute.httpHealthChecks.useReadOnly", "compute.httpsHealthChecks.useReadOnly", "compute.images.create", "compute.images.delete", "compute.images.get", "compute.images.list", "compute.images.useReadOnly", "compute.instanceGroupManagers.get", "compute.instanceGroups.create", "compute.instanceGroups.get", "compute.instanceGroups.list", "compute.instanceGroups.update", "compute.instanceGroups.use", "compute.instanceTemplates.get", "compute.instances.attachDisk", "compute.instances.create", "compute.instances.delete", "compute.instances.get", "compute.instances.list", "compute.instances.listReferrers", "compute.instances.setLabels", "compute.instances.setMetadata", "compute.instances.setServiceAccount", "compute.instances.setTags", "compute.instances.start", "compute.instances.stop", "compute.instances.use", "compute.instances.update", "compute.instances.setDiskAutoDelete", "compute.machineTypes.get", "compute.machineTypes.list", "compute.networks.get", "compute.networks.list", "compute.projects.get", "compute.regionBackendServices.get", "compute.regionBackendServices.list", "compute.regionBackendServices.update", "compute.regionOperations.get", "compute.regionOperations.list", "compute.snapshots.create", "compute.snapshots.delete", "compute.snapshots.get", "compute.snapshots.list", "compute.subnetworks.use", "compute.subnetworks.useExternalIp", "compute.targetPools.addInstance", "compute.targetPools.get", "compute.targetPools.list", "compute.targetPools.removeInstance", "compute.zoneOperations.get", "compute.zoneOperations.list", "compute.zones.list", "container.clusterRoleBindings.create", "container.clusterRoles.bind", "container.clusters.get", "container.clusters.list", "container.clusters.update", "container.operations.get", "container.operations.list", "iam.serviceAccounts.get", "iam.serviceAccounts.list", "iam.serviceAccounts.update", "monitoring.metricDescriptors.list", "monitoring.timeSeries.list", "servicemanagement.services.check", "servicemanagement.services.report"]
}

resource "google_service_account" "spotserviceaccount" {
	provisioner "local-exec" {
	    # Without this set-cloud-credentials fails 
	    command = "sleep 10"
	}
	account_id      = "spot-${random_id.role.hex}"
	display_name    = "spot-${random_id.role.hex}"
	description     = "Service Account for Spot.io"
	project         = var.project
}

resource "google_service_account_key" "key" {
  service_account_id = google_service_account.spotserviceaccount.name
}

resource "google_project_iam_binding" "spot-account-iam" {
    project = var.project
    role    = google_project_iam_custom_role.SpotRole.name
    members = [
        "serviceAccount:spot-${random_id.role.hex}@${var.project}.iam.gserviceaccount.com",
    ]
}

# Call Spot API to create the Spot Account 
resource "null_resource" "account" {
    triggers = {
        cmd     = "${path.module}/scripts/spot-account"
        name    = var.project
        token   = var.spotinst_token
    }
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command     = "${self.triggers.cmd} create ${self.triggers.name} --token=${self.triggers.token}"
    }
    provisioner "local-exec" {
        when = destroy
        interpreter = ["/bin/bash", "-c"]
        command = <<-EOT
            ID=$(${self.triggers.cmd} get --filter=name=${self.triggers.name} --attr=account_id --token=${self.triggers.token}) &&\
            ${self.triggers.cmd} delete "$ID" --token=${self.triggers.token}
        EOT
    }
}


# Link the service account to the Spot Account
resource "null_resource" "account_association" {
    depends_on = [google_project_iam_binding.spot-account-iam]
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} set-cloud-credentials ${local.account_id} ${local.private_key} --token=${var.spotinst_token}"
    } 
}