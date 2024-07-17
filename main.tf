resource "google_storage_bucket" "raw_logs" {
  name          = "${var.project_id}-raw-logs"
  location      = "US"
  force_destroy = true
}

# Use local-exec to upload a file to the bucket
resource "null_resource" "upload_files" {
  triggers = {
    # Use a timestamp to force a run on each apply
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
      # Retrieve the bucket URL from Terraform output
      BUCKET_URL=$(terraform output -raw raw_logs_bucket)

      # Upload a file to the bucket
      gsutil cp ./sample-logs/* $BUCKET_URL
      gsutil cp ./scripts/dataflow.py $BUCKET_URL
    EOT
  }
  depends_on = [google_storage_bucket.raw_logs]
}

resource "google_bigquery_dataset" "logs_dataset" {
  dataset_id = "logs_dataset"
  location   = "US"
}

resource "google_bigquery_table" "processed_logs" {
  dataset_id = google_bigquery_dataset.logs_dataset.dataset_id
  table_id   = "processed_logs"

  schema = <<EOF
    [
    {"name": "timestamp", "type": "TIMESTAMP", "mode": "NULLABLE"},
    {"name": "level", "type": "STRING", "mode": "REQUIRED"},
    {"name": "message", "type": "STRING", "mode": "REQUIRED"}
    ]
    EOF
}
