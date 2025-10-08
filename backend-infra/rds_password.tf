# Random Password for RDS Admin
resource "random_password" "db_admin_password" {
  length           = 16
  special          = true
  override_special = "!$%^&*()-_=+?"
}