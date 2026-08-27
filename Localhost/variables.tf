variable "postgres_user" {
  type        = string
  default     = "postgres"
  description = "Usuario de PostgreSQL"
}

variable "postgres_password" {
  type        = string
  default     = "postgres123"
  sensitive   = true
  description = "Contraseña de PostgreSQL"
}

variable "postgres_db" {
  type        = string
  default     = "n8n_db"
  description = "Base de datos para n8n"
}

variable "n8n_port" {
  type        = number
  default     = 5678
  description = "Puerto expuesto de n8n"
}