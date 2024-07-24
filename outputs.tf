output "raw_logs_bucket" {
  value = google_storage_bucket.raw_logs.url
}

output "new_logs_bucket" {
  value = google_storage_bucket.new_logs_bucket.url
}