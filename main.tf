terraform {
  required_version = ">= 1.5.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {
  # En Linux usa: "unix:///var/run/docker.sock"
  # En Windows/Docker Desktop suele ser: "npipe:////.//pipe/docker_engine"
  host = "unix:///var/run/docker.sock"
}

# Red interna compartida
resource "docker_network" "app_network" {
  name = "personal_apps_network"
}

# -----------------------------
# Volúmenes (Persistencia)
# -----------------------------
resource "docker_volume" "postgres_data" {
  name = "pg_data_storage"
}

resource "docker_volume" "n8n_data" {
  name = "n8n_data_storage"
}

# -----------------------------
# Imágenes Docker
# -----------------------------
resource "docker_image" "postgres" {
  name         = "postgres:16-alpine"
  keep_locally = true
}

resource "docker_image" "n8n" {
  name         = "n8nio/n8n:latest"
  keep_locally = true
}

# -----------------------------
# Contenedor PostgreSQL
# -----------------------------
resource "docker_container" "postgres" {
  name  = "postgres-db"
  image = docker_image.postgres.image_id

  restart = "always"

  networks_advanced {
    name = docker_network.app_network.name
  }

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  ports {
    internal = 5432
    external = 5432
  }
}

# -----------------------------
# Contenedor n8n (Conectado a PostgreSQL)
# -----------------------------
resource "docker_container" "n8n" {
  name  = "n8n-app"
  image = docker_image.n8n.image_id

  restart = "always"

  depends_on = [docker_container.postgres]

  networks_advanced {
    name = docker_network.app_network.name
  }

  env = [
    "DB_TYPE=postgresdb",
    "DB_POSTGRESDB_HOST=postgres-db",
    "DB_POSTGRESDB_PORT=5432",
    "DB_POSTGRESDB_DATABASE=${var.postgres_db}",
    "DB_POSTGRESDB_USER=${var.postgres_user}",
    "DB_POSTGRESDB_PASSWORD=${var.postgres_password}",
    "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true",
    "GENERIC_TIMEZONE=America/Bogota",
    "TZ=America/Bogota"
  ]

  volumes {
    volume_name    = docker_volume.n8n_data.name
    container_path = "/home/node/.n8n"
  }

  ports {
    internal = 5678
    external = var.n8n_port
  }
}