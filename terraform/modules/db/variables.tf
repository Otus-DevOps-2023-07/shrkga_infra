variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  description = "SSH private key"
}
variable "db_disk_image" {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
variable "subnet_id" {
  description = "Subnets for modules"
}
variable "app_count" {
  description = "Instances count"
  default     = 1
}
variable "environment" {
  description = "Prod or stage"
}
variable "provision" {
  description = "Enable provisioning or not"
  type        = bool
  default     = false
}
