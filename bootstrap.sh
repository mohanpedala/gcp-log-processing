gcloud projects create log-processing-12345

gcloud config set project your-project-id


## link billing account
gcloud services enable storage.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable bigquery.googleapis.com


gcloud storage buckets create gs://my-unique-bucket-name-12345 --location=US


## Create gcloud service accocunt to run the terraform code
# Create a Service Account:

# Go to the Google Cloud Console IAM & Admin page.
# Click "Create Service Account."
# Enter a name for the service account (e.g., terraform-admin).
# Click "Create."
# Assign Roles:

# Assign the appropriate roles to the service account. For Terraform to manage resources, you'll typically need roles like Editor or more specific roles depending on your needs.
# Click "Continue" and then "Done."
# Create a Key:

# Find the service account you just created in the list.
# Click on the service account name.
# Go to the "Keys" tab.
# Click "Add Key" and select "JSON" to create a new key.
# Download the JSON key file and save it to a secure location.

# On Linux or macOS, use:

# sh
# Copy code
# export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/keyfile.json"