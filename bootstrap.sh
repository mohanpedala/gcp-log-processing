#!/bin/bash

# Variables
PROJECT_ID="log-processing-12345"
BUCKET_NAME=$PROJECT_ID-"terraform-state"
SERVICE_ACCOUNT_NAME="log-processing-terraform"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

# Create GCP Project
gcloud projects create $PROJECT_ID

# Set the created project as the default project
gcloud config set project $PROJECT_ID

# Enable required services
gcloud services enable storage.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable bigquery.googleapis.com

# Create a storage bucket
gcloud storage buckets create gs://$BUCKET_NAME --location=US

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

# Create a Service Account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --description="Service account for Terraform management" \
    --display-name="Terraform Admin"

# Assign roles to the Service Account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/storage.objectViewer

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/storage.objectAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/dataflow.admin

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT_EMAIL \
    --role=roles/bigquery.dataEditor

# Create a JSON key for the Service Account
gcloud iam service-accounts keys create ~/keyfile.json \
    --iam-account $SERVICE_ACCOUNT_EMAIL

echo "Service account key saved to ~/keyfile.json"
echo "Remember to set the GOOGLE_APPLICATION_CREDENTIALS environment variable:"
echo "export GOOGLE_APPLICATION_CREDENTIALS=\"~/keyfile.json\""
