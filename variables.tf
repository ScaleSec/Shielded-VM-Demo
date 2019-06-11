####################
# Required Variables
####################
variable "project_id" {
  description = "The Project to deploy resources into"
}

variable "notification_email_address" {
  description = "The Email Address which should recieve notifications for Shielded VM Failures"
}

variable "stackdriver_project" {
  description = "The Project ID of the Stackdriver Workspace which to deploy the Stackdriver Alerts.  If you stackdriver workspace is in the same project as your resources, set this variable equal to the project_id"
}

####################
# Optional Variables
####################

variable "region" {
  description = "The Region to deploy resources into"
  default     = "us-east1"
}

variable "shielded_vm_image" {
  description = "The VM Image to deploy.  Image must be compatible with shielded VM"
  default     = "gce-uefi-images/ubuntu-1804-lts"
}

variable "subnet_cidr_range" {
  description = "The IPV4 Range for the Network"
  default     = "192.168.1.0/24"
}

variable "zone" {
  description = "The Zone which to deploy the VM into"
  default     = "us-east1-b"
}

variable "enable_secure_boot" {
  description = "Enable Secure Boot feature in Shielded VM?"
  default     = true
}

variable "enable_vtpm" {
  description = "Enable Virtual TPM feature in Shielded VM?"
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Enable Integrity Monitoring feature in Shielded VM?"
  default     = true
}

