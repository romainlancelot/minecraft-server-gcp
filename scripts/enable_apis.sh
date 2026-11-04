#!/bin/bash
set -e

# Configuration
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    read -p "Enter your GCP Project ID: " PROJECT_ID
fi

echo "============================================="
echo "Enabling required GCP APIs for Minecraft"
echo "Project: $PROJECT_ID"
echo "============================================="

gcloud services enable \
  compute.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  serviceusage.googleapis.com \
  --project="$PROJECT_ID"

echo ""
echo "✅ All required APIs have been successfully enabled!"
