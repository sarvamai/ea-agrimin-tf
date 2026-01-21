terraform {
  backend "gcs" {
    bucket = "s-0-000236-188-tfstate"
    prefix = "01-network"
  }
}