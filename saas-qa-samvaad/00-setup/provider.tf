terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.15.0"
    }
  }
}
provider "google" {
  project = var.project_id
  region  = "asia-south1"
  billing_project = var.project_id
  user_project_override = true
}