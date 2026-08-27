variable "gcp_project_id" {
  description = "El ID del proyecto en Google Cloud"
  type        = string
}

variable "gcp_region" {
  description = "Region principal para desplegar recursos"
  type        = string
  default     = "us-central1"
}

variable "gcp_location" {
  description = "Ubicacion para BigQuery y GCS (us-central1 o multiregion US)"
  type        = string
  default     = "US"
}

variable "data_lake_bucket_name" {
  description = "Nombre unico global para el bucket del Data Lake"
  type        = string
}

variable "bq_dataset_name" {
  description = "Nombre del dataset en BigQuery"
  type        = string
  default     = "analytics_lakehouse"
}

# -------------------------------------------------------------
# Flags de Activación Opcional (Feature Toggles)
# -------------------------------------------------------------
variable "enable_dataform" {
  description = "Activar o desactivar la creación del repositorio Dataform"
  type        = bool
  default     = false # Por defecto apagado
}

variable "enable_backup_bucket" {
  description = "Activar o desactivar un bucket de respaldo frío"
  type        = bool
  default     = false # Por defecto apagado
}