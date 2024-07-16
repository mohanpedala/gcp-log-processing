resource "google_storage_bucket" "raw_logs" {
  name          = "${var.project_id}-raw-logs"
  location      = "US"
  force_destroy = true
}

# Use local-exec to upload a file to the bucket
resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = <<EOT
      # Retrieve the bucket URL from Terraform output
      BUCKET_URL=$(terraform output -raw raw_logs_bucket)

      # Upload a file to the bucket
      gsutil cp ./sample-logs/* $BUCKET_URL
      gsutil cp ./scripts/* $BUCKET_URL
    EOT
  }
  depends_on = [google_storage_bucket.raw_logs]
}
