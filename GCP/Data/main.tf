# Obtener dinámicamente el número de proyecto para los Service Agents de GCP
data "google_project" "current" {
  project_id = var.gcp_project_id
}

# -------------------------------------------------------------
# 1. Cloud Storage: Data Lake (Capas Raw, Staging, Curated)
# -------------------------------------------------------------
resource "google_storage_bucket" "data_lake" {
  name          = var.data_lake_bucket_name
  location      = var.gcp_location
  force_destroy = true 

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
}

# Carpetas virtuales (Medallion Architecture)
resource "google_storage_bucket_object" "folder_raw" {
  name    = "raw/"
  content = " "
  bucket  = google_storage_bucket.data_lake.name
}

resource "google_storage_bucket_object" "folder_staging" {
  name    = "staging/"
  content = " "
  bucket  = google_storage_bucket.data_lake.name
}

resource "google_storage_bucket_object" "folder_curated" {
  name    = "curated/"
  content = " "
  bucket  = google_storage_bucket.data_lake.name
}

# -------------------------------------------------------------
# 2. BigQuery: Data Warehouse / Lakehouse
# -------------------------------------------------------------
resource "google_bigquery_dataset" "lakehouse_dataset" {
  dataset_id                  = var.bq_dataset_name
  friendly_name               = "Analytics Lakehouse"
  description                 = "Dataset analítico gestionado por Terraform"
  location                    = var.gcp_location
  delete_contents_on_destroy  = true

  labels = {
    env      = "dev"
    pipeline = "data-engineering"
  }
}

# -------------------------------------------------------------
# 3. Seguridad: SA de Ingesta Externa (Python / n8n / APIs)
# -------------------------------------------------------------
resource "google_service_account" "ingestion_sa" {
  account_id   = "sa-data-ingestion"
  display_name = "SA Ingesta de Datos"
  description  = "Solo escribe y lee archivos en el Data Lake (GCS)"
}

resource "google_storage_bucket_iam_member" "gcs_ingestion_access" {
  bucket = google_storage_bucket.data_lake.name
  role   = "roles/storage.objectUser"
  member = "serviceAccount:${google_service_account.ingestion_sa.email}"
}

# Clave JSON descargable para scripts externos
resource "google_service_account_key" "ingestion_sa_key" {
  service_account_id = google_service_account.ingestion_sa.name
}

# -------------------------------------------------------------
# 4. Seguridad: SA de Dataform (Transformaciones en BigQuery)
# -------------------------------------------------------------
resource "google_service_account" "dataform_sa" {
  count        = var.enable_dataform ? 1 : 0
  account_id   = "sa-dataform-executor"
  display_name = "SA Dataform Executor"
  description  = "Ejecuta consultas y transformaciones en BigQuery"
}

resource "google_project_iam_member" "dataform_bq_editor" {
  count   = var.enable_dataform ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.dataform_sa[0].email}"
}

resource "google_project_iam_member" "dataform_bq_job_user" {
  count   = var.enable_dataform ? 1 : 0
  project = var.gcp_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.dataform_sa[0].email}"
}

# -------------------------------------------------------------
# 5. Recursos Opcionales: Repositorio Dataform y Backup Bucket
# -------------------------------------------------------------
resource "google_dataform_repository" "transformation_repo" {
  provider = google-beta

  count   = var.enable_dataform ? 1 : 0
  name    = "data-transformations-repo"
  region  = var.gcp_region
  project = var.gcp_project_id
}

resource "google_storage_bucket" "backup_lake" {
  count         = var.enable_backup_bucket ? 1 : 0
  name          = "${var.data_lake_bucket_name}-backups"
  location      = var.gcp_location
  storage_class = "COLDLINE"
  force_destroy = true
}