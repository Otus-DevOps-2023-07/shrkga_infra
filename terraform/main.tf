# Crutches for non-working tests
### terraform block has been moved to the config.tf file, because code doesn't pass validation on outdated github actions tests

# terraform {
#   required_version = "~> 1.5.1"
#   required_providers {
#     yandex = {
#       source  = "yandex-cloud/yandex"
#       version = "~> 0.95.0"
#     }
#   }
# }

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
