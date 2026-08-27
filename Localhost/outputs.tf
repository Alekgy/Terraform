output "n8n_url" {
  value       = "http://localhost:${var.n8n_port}"
  description = "Acceso a la interfaz web de n8n"
}

output "postgres_connection" {
  value       = "postgresql://${var.postgres_user}:****@localhost:5432/${var.postgres_db}"
  description = "Cadena de conexión de PostgreSQL"
}