resource "google_storage_bucket" "raw_logs" {
  name          = "${var.project_id}-raw-logs"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket" "new_logs_bucket" {
  name          = "${var.project_id}-new-logs-bucket"
  location      = "US"
  force_destroy = true
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_storage_bucket.new_logs_bucket, google_storage_bucket.raw_logs]

  create_duration = "10s"
}

# Use local-exec to upload a file to the bucket
resource "null_resource" "upload_files" {
  depends_on = [time_sleep.wait_30_seconds]
  triggers = {
    # Use a timestamp to force a run on each apply
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
      # Retrieve the bucket URL from Terraform output
      BUCKET_URL=$(terraform output -raw raw_logs_bucket)

      # Retrieve the new logs bucket URL from Terraform output
      NEW_LOGS_BUCKET_URL=$(terraform output -raw new_logs_bucket)

      # Upload a file to the bucket
      gsutil cp ./sample-logs/* gs://log-processing-12345-new-logs-bucket
      gsutil cp ./scripts/dataflow.py $BUCKET_URL
    EOT
  }
}

resource "google_bigquery_dataset" "logs_dataset" {
  dataset_id = "logs_dataset"
  location   = "US"
}

resource "google_bigquery_table" "processed_logs" {
  dataset_id          = google_bigquery_dataset.logs_dataset.dataset_id
  table_id            = "processed_logs"
  deletion_protection = false

  schema = <<EOF
    [
    {"name": "timestamp", "type": "TIMESTAMP", "mode": "NULLABLE"},
    {"name": "log_level", "type": "STRING", "mode": "NULLABLE"},
    {"name": "message", "type": "STRING", "mode": "NULLABLE"}
    ]
    EOF
}
