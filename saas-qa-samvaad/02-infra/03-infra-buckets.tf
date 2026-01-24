resource "google_storage_bucket" "postgres_backup_storage" {
  name                        = "${local.env_prefix}-pg-backup-${local.project_id}"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 14
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "clickhouse_backup" {
  name                        = "${local.env_prefix}-chi-backup"
  location                    = local.region
  force_destroy               = false
  storage_class               = "STANDARD"
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true # Use IAM only (prevents messy ACLs)

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 14
    }
    action {
      type = "Delete"
    }
  }
}

##################
# Openbao Backup
#################
resource "google_storage_bucket" "openbao_backup_storage" {
  name                        = "${local.env_prefix}-openbao-backup"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 14
    }
    action {
      type = "Delete"
    }
  }
}

##########
# Thanos
##########
resource "google_storage_bucket" "thanos_storage" {
  name                        = "${local.env_prefix}-thanos-backup"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 180
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 360
    }
    action {
      type = "Delete"
    }
  }
}

########
# Kafka
########
resource "google_storage_bucket" "kafka_storage" {
  name                        = "${local.env_prefix}-kafka"
  location                    = local.region
  project                     = local.project_id
  force_destroy               = false
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  labels                      = local.default_labels
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 14
    }
    action {
      type = "Delete"
    }
  }
}
