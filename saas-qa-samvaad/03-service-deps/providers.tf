terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>7.15.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~>7.15.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }
  }
}
provider "google" {
  project = local.project_id
  region  = local.region
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
}

provider "kubernetes" {
  host  = "https://${local.cluster_dns_endpoint}"
  token = data.google_client_config.main.access_token
}

provider "helm" {
  kubernetes = {
    host  = "https://${local.cluster_dns_endpoint}"
    token = data.google_client_config.main.access_token
  }
}

provider "kubectl" {
  host  = "https://${local.cluster_dns_endpoint}"
  token = data.google_client_config.main.access_token
}