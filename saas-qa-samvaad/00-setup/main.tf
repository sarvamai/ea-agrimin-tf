resource "null_resource" "enable_crm_api" {
  provisioner "local-exec" {
    command     = "gcloud services enable cloudresourcemanager.googleapis.com --project=${var.project_id}"
    interpreter = ["cmd", "/C"]
  }
}

resource "google_project_service" "main" {
  for_each = toset([
    "billingbudgets.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "certificatemanager.googleapis.com",
    "cloudidentity.googleapis.com",
    "secretmanager.googleapis.com",
    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudkms.googleapis.com"
  ])
  service                    = each.value
  project                    = var.project_id
  disable_dependent_services = true
  depends_on                 = [null_resource.enable_crm_api] # Ensure CRM API is enabled first
}

# Wait for 2 minutes after enabling APIs
resource "time_sleep" "wait_for_apis" {
  depends_on      = [google_project_service.main]
  create_duration = "2m"
}

resource "google_service_account" "managment_vm_service_account" {
  project      = var.project_id
  account_id   = "mgmt-vm-${var.env_prefix}"
  display_name = "Management VM Service Account ${var.env_prefix}"
  depends_on   = [time_sleep.wait_for_apis]
}

resource "google_project_iam_member" "managment_vm_sa_roles" {
  for_each   = toset(var.vm_iam_roles)
  project    = var.project_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.managment_vm_service_account.email}"
  depends_on = [time_sleep.wait_for_apis]
}

resource "google_service_account" "node_pool_service_account" {
  project      = var.project_id
  account_id   = "node-pool-${var.env_prefix}-sa"
  display_name = "Node Pool Service Account ${var.env_prefix}"
}

resource "google_project_iam_member" "node_pool_sa_roles" {
  for_each   = toset(var.node_pool_iam_roles)
  project    = var.project_id
  role       = each.value
  member     = "serviceAccount:${google_service_account.node_pool_service_account.email}"
  depends_on = [time_sleep.wait_for_apis]
}

/* Cloud Identity integration removed: customer_id and group membership
   were causing errors. If you want to re-enable, provide a Cloud Identity
   customer ID in terraform.tfvars and restore the blocks. */
/*
resource "google_storage_bucket_iam_member" "admin-member" {
  bucket = "sarvam-gcp-tfstates"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.managment_vm_service_account.email}"
}

resource "google_storage_bucket_iam_member" "storage-member" {
  bucket = "sarvam-gcp-tfstates"
  role   = "roles/storage.bucketViewer"
  member = "serviceAccount:${google_service_account.managment_vm_service_account.email}"
}
*/

# Billing Notification
# resource "google_monitoring_notification_channel" "billing_alerts" {
#   for_each = {
#     for person in var.notification_emails :
#     person.name => person
#   }

#   project      = var.project_id
#   display_name = "Billing Alert - ${each.value.name}"
#   type         = "email"

#   labels = {
#     email_address = each.value.email
#   }
# }

# resource "google_billing_budget" "billing_alert" {
#   billing_account = "013267-406EA4-1ABDD5"
#   display_name    = "billing_alert"

#   budget_filter {
#     projects               = ["projects/${var.project_number}"]
#     credit_types_treatment = "EXCLUDE_ALL_CREDITS"
#     calendar_period        = "MONTH"
#   }

#   amount {
#     specified_amount {
#       currency_code = "INR"
#       units         = 87000
#     }
#   }

#   threshold_rules {
#     threshold_percent = 0.5
#   }

#   threshold_rules {
#     threshold_percent = 0.7
#   }

#   threshold_rules {
#     threshold_percent = 1.0
#   }

#   all_updates_rule {
#     monitoring_notification_channels = [
#       for k, v in google_monitoring_notification_channel.billing_alerts : v.id
#     ]
#     disable_default_iam_recipients = false
#   }
# }