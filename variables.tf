variable "project" {
  type        = string
  description = "Name of the project to connect to Spot"
}

variable "spotinst_token" {
  type        = string
  description = "Spotinst API Token"
  sensitive   = true
}

variable "debug" {
  type        = bool
  description = "Add flag to expose sensitive variables for troubleshooting"
  default     = false
}

