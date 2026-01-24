resource "google_storage_bucket" "app_storage" {
  name                        = "${local.env_prefix}-moa-app-storage"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "publicaccess_storage" {
  name                        = "${local.env_prefix}-publicaccess"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "ces_storage" {
  name                        = "${local.env_prefix}-ces-storage"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "kb_storage" {
  name                        = "${local.env_prefix}-kb-storage"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "public_app_storage" {
  name                        = "${local.env_prefix}-public-app-storage"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "failed_events_storage" {
  name                        = "${local.env_prefix}-failed-events"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  versioning {
    enabled = true
  }
}