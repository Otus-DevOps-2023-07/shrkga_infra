output "external_ip_address_app" {
  value = module.app.external_ip_address_app
}
output "external_ip_address_db" {
  value = module.db.external_ip_address_db
}
output "internal_ip_address_db" {
  value = module.db.internal_ip_address_db
}

### The Ansible inventory file
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl", {
    external_ip_address_app = module.app.external_ip_address_app.0
    external_ip_address_db  = module.db.external_ip_address_db.0
    internal_ip_address_db  = module.db.internal_ip_address_db.0
  })
  filename = "../../ansible/inventory_${var.environment}.yml"
}
