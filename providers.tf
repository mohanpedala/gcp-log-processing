terraform {
  backend "gcs" {
    bucket = "log-processing-terraform-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = "log-processing-12345"
  region  = "us-central1"
}