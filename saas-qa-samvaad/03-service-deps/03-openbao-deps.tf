###########
# Openbao
##########
resource "google_service_account" "openbao_sa" {
  account_id   = "${local.env_prefix}openbao-sa"
    lifecycle {
      prevent_destroy = true
    }
  display_name = "OpenBao Service Account"
}

# Cloud KMS Keyring and Key
# This key will be used to encrypt/decrypt (wrap/unwrap) OpenBao's highly sensitive internal master key.
resource "google_kms_key_ring" "openbao_keyring" {
  name     = "openbao-keyring"
  location = local.region
}

# OpenBao uses this key to encrypt (wrap) its internal master key.
# This key's sole job is to encrypt and decrypt the OpenBao Master Key.
resource "google_kms_crypto_key" "openbao_key" {
  name     = "openbao-seal-key"
  key_ring = google_kms_key_ring.openbao_keyring.id
  purpose  = "ENCRYPT_DECRYPT"
  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

# Grant GSA KMS Encryption/Decryption Permissions
resource "google_kms_crypto_key_iam_member" "kms_access" {
  crypto_key_id = google_kms_crypto_key.openbao_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.openbao_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "kms_access_viewer" {
  crypto_key_id = google_kms_crypto_key.openbao_key.id
  role          = "roles/cloudkms.viewer"
  member        = "serviceAccount:${google_service_account.openbao_sa.email}"
}

resource "google_service_account_iam_member" "openbao_sa_workload_binding" {
  service_account_id = google_service_account.openbao_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[openbao/openbao-sa]"
}

#################
# Openbao Backup
################
resource "google_service_account" "openbao_backup_sa" {
  account_id   = "${local.env_prefix}-openbao-bkp-sa"
    lifecycle {
      prevent_destroy = true
    }
  display_name = "OpenBao Backup Service Account"
}

resource "google_storage_bucket_iam_member" "openbao_backup_bucket_binding" {
  bucket = local.openbao_backup_bucket_name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.openbao_backup_sa.email}"
}

resource "google_service_account_iam_member" "openbao_backupsa_workload_binding" {
  service_account_id = google_service_account.openbao_backup_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[openbao/openbao-backup-sa]"
}

locals {
  openbao_service_account = {
    "openbao-openbao" = {
      "name"                 = "openbao-sa"
      "namespace"            = "openbao"
      "service_account_name" = "openbao-sa"
      "sa_email"             = google_service_account.openbao_sa.email
    }
  }
  openbao_backup_service_account = {
    "openbao-openbao-backup" = {
      "name"                 = "openbao-backup-sa"
      "namespace"            = "openbao"
      "service_account_name" = "openbao-backup-sa"
      "sa_email"             = google_service_account.openbao_backup_sa.email
    }
  }
}
