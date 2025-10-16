# Random Password for RDS Admin
resource "random_password" "db_admin_password" {
  length           = 16
  special          = true
  # Excluded bash problematic charcters: $, !, ", ', \, `
  override_special = "_+-=.@#^*?"
}