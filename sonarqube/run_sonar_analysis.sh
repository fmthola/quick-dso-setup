#!/bin/bash

# --- Configuration ---
# 🚨 ENSURE THIS IS CORRECT (e.g., host.docker.internal:9000 or a specific IP)
SONARQUBE_URL="http://10.10.200.76:9000" 
YOUR_REPO=$(pwd)                           
PROJECT_BASE_DIR=$(pwd) # The directory being analyzed

# --- 1. Define Universal Project Properties ---
# Get the name of the current directory (the last component of the path)
# This uses the shell's parameter expansion to strip the path and get the folder name.
PROJECT_KEY=$(basename "${PROJECT_BASE_DIR}")
PROJECT_NAME="${PROJECT_KEY}" # Use the key as the name for simplicity

echo "Project Key: ${PROJECT_KEY}"
echo "Project Name: ${PROJECT_NAME}"
echo "---------------------------------------------------------"

# --- 2. Retrieve the SonarQube Token using the Python script ---
echo "Attempting to retrieve SonarQube token from keyring..."
# Use the full path to the Python script for robust execution
SCRIPT_DIR=$(dirname "$0")
SONAR_TOKEN=$(./get_sonarqube_token.py)

# Check for successful retrieval (omitted for brevity, assume it still works)
if [ -z "$SONAR_TOKEN" ]; then
    echo "❌ ERROR: Token retrieval failed. Please ensure the 'set' script was run."
    exit 1
fi

echo "✅ Token successfully retrieved (first 5 characters: ${SONAR_TOKEN:0:5}*****)."
echo "--- Starting SonarScanner Docker analysis ---"

# --- 3. Execute the Docker Command with Mandatory Properties ---
# The mandatory project properties (sonar.projectKey and sonar.projectName) 
# must be passed as -D properties via the SONAR_SCANNER_OPTS environment variable.
sudo docker run \
    --rm \
    --add-host="host.docker.internal:host-gateway" \
    -e SONAR_HOST_URL="${SONARQUBE_URL}" \
    -e SONAR_TOKEN="${SONAR_TOKEN}" \
    -e SONAR_SCANNER_OPTS="-Dsonar.projectKey=${PROJECT_KEY} -Dsonar.projectName=${PROJECT_NAME}" \
    -v "${YOUR_REPO}:/usr/src" \
    sonarsource/sonar-scanner-cli

# Exit status check...
if [ $? -eq 0 ]; then
    echo "✅ SonarScanner analysis completed successfully."
else
    echo "❌ SonarScanner analysis failed."
fi
