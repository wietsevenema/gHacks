terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.27.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
}

data "google_project" "project" {}

# Artifact Registry API
resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

# Cloud Build API
resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
}

# Cloud Resource Manager API
resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}

# Cloud Datastore API
resource "google_project_service" "datastore" {
  service = "datastore.googleapis.com"
}

# Identity and Access Management (IAM) API
resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

# Cloud Monitoring API
resource "google_project_service" "monitoring" {
  service = "monitoring.googleapis.com"
}

# Cloud Pub/Sub API
resource "google_project_service" "pubsub" {
  service = "pubsub.googleapis.com"
}

# Google Cloud Memorystore for Redis API
resource "google_project_service" "redis" {
  service = "redis.googleapis.com"
}

# Cloud Run Admin API
resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

# Secret Manager API
resource "google_project_service" "secretmanager" {
  service = "secretmanager.googleapis.com"
}

# Service Management API
resource "google_project_service" "servicemanagement" {
  service = "servicemanagement.googleapis.com"
}

# Service Usage API
resource "google_project_service" "serviceusage" {
  service = "serviceusage.googleapis.com"
}

# Cloud SQL Admin API
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}

# Serverless VPC Access API
resource "google_project_service" "vpcaccess" {
  service = "vpcaccess.googleapis.com"
}

# Cloud Deploy API
resource "google_project_service" "clouddeploy" {
  service = "clouddeploy.googleapis.com"
}

# MemoryStore instance
resource "google_redis_instance" "instance" {  
  connect_mode            = "DIRECT_PEERING"
  memory_size_gb          = 1
  name                    = "redis"  
  read_replicas_mode      = "READ_REPLICAS_DISABLED"
  redis_version           = "REDIS_6_X"
  region                  = var.gcp_region
  tier                    = "BASIC"
  transit_encryption_mode = "DISABLED"
  depends_on = [
    google_project_service.redis
  ]
}

# Cloud SQL instance
resource "google_sql_database_instance" "instance" {
  database_version = "POSTGRES_14"
  name             = "postgres"  
  region           = var.gcp_region

  depends_on = [
    google_project_service.sqladmin
  ]

  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"

    backup_configuration {
      enabled                        = false
      point_in_time_recovery_enabled = false
    }

    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_HDD"

    ip_configuration {
      ipv4_enabled = true
    }

    pricing_plan = "PER_USE"
    tier         = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = "database"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "app"
  instance = google_sql_database_instance.instance.name
  password     = "my-precious"
}





