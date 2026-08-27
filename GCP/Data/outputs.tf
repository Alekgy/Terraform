output "bucket_url" {
  description = "URI del Data Lake"
  value       = google_storage_bucket.data_lake.url
}

output "bigquery_dataset_id" {
  description = "ID del dataset en BigQuery"
  value       = google_bigquery_dataset.lakehouse_dataset.dataset_id
}

output "ingestion_service_account_email" {
  description = "Email de la SA para ingesta externa"
  value       = google_service_account.ingestion_sa.email
}

output "ingestion_sa_private_key_base64" {
  description = "Clave privada en base64 para tus scripts de ingesta"
  value       = google_service_account_key.ingestion_sa_key.private_key
  sensitive   = true
}

output "dataform_service_account_email" {
  description = "Email de la SA usada por Dataform"
  value       = var.enable_dataform ? google_service_account.dataform_sa[0].email : "Desactivado"
}

output "dataform_repo_id" {
  description = "ID del repositorio Dataform"
  value       = var.enable_dataform ? google_dataform_repository.transformation_repo[0].id : "Desactivado"
}