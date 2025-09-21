#!/bin/bash

# --- Script Configuration ---
# Set the desired version tag. 'latest' is the default.
SONAR_VERSION="latest" 
# Set the container name
SONAR_CONTAINER_NAME="sonarqube-scanner"
# Set the volume name for persistent data
SONAR_VOLUME="sonarqube_data"
# Port for the SonarQube web interface
HOST_WEB_PORT=9000
# Port for the internal database
HOST_DB_PORT=9092
# ----------------------------

echo "Starting SonarQube Docker Setup..."

# 1. Stop and remove any existing container with the same name
if sudo docker ps -a --format '{{.Names}}' | grep -q "$SONAR_CONTAINER_NAME"; then
    echo "Stopping and removing old container: $SONAR_CONTAINER_NAME"
    sudo docker stop "$SONAR_CONTAINER_NAME"
    sudo docker rm "$SONAR_CONTAINER_NAME"
fi

# 2. Pull the latest official SonarQube image
echo "Pulling SonarQube image: sonarqube:$SONAR_VERSION"
sudo docker pull sonarqube:"$SONAR_VERSION"

# 3. Create a persistent volume for SonarQube data (if it doesn't exist)
if ! sudo docker volume ls --format '{{.Name}}' | grep -q "$SONAR_VOLUME"; then
    echo "Creating persistent volume: $SONAR_VOLUME"
    sudo docker volume create "$SONAR_VOLUME"
fi

# 4. Run the SonarQube container
echo "Running SonarQube container..."
sudo docker run -d \
    --name "$SONAR_CONTAINER_NAME" \
    -p "$HOST_WEB_PORT":9000 \
    -p "$HOST_DB_PORT":9092 \
    -v "$SONAR_VOLUME":/opt/sonarqube/data \
    sonarqube:"$SONAR_VERSION"

# 5. Provide access information
if [ $? -eq 0 ]; then
    echo "---------------------------------------------------"
    echo "✅ SonarQube is starting up (this may take a few minutes)!"
    echo "Access the Web Interface at: http://localhost:$HOST_WEB_PORT"
    echo "Default Credentials: admin / admin"
    echo "Container Name: $SONAR_CONTAINER_NAME"
    echo "To check the logs: docker logs -f $SONAR_CONTAINER_NAME"
    echo "---------------------------------------------------"
else
    echo "❌ ERROR: Failed to start the SonarQube container."
    echo "Check your Docker installation and system resources."
fi
