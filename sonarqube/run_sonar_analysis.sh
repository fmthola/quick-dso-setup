# SonarQube Host URL (Must match your server's configuration)

SONAR_HOST_URL="http://10.10.200.76:9000"

# --- Automatic Variable Derivation ---
# The project directory is the current directory where the script is run.
PROJECT_DIR="$(pwd)"

# The project name is the name of the current directory.
PROJECT_NAME=$(basename "$PROJECT_DIR")

# Automatically derive a unique project key from the project name
# Replaces spaces and special characters with hyphens and converts to lowercase
PROJECT_KEY=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9\n' '-' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')

# Get the token from the Python script
SONAR_TOKEN=$(python get_sonarqube_token.py)

# Check if the token was successfully retrieved
if [ -z "$SONAR_TOKEN" ]; then
    echo "❌ Error: SonarQube token not found. Please run set_sonarqube_token.py first."
    exit 1
fi

echo "Starting SonarQube analysis for project: $PROJECT_NAME"
echo "Project Key: $PROJECT_KEY"

# --- Run the SonarScanner analysis inside a Docker container ---
# The token is now passed as a system property directly to sonar-scanner,
# which is a more robust way of handling credentials.
sudo docker run \
  --rm \
  -e SONAR_HOST_URL="$SONAR_HOST_URL" \
  -v "$PROJECT_DIR":/usr/src \
  sonarsource/sonar-scanner-cli \
  -Dsonar.login="$SONAR_TOKEN" \
  -Dsonar.projectKey="$PROJECT_KEY" \
  -Dsonar.projectName="$PROJECT_NAME" \
  -Dsonar.qualitygate.wait=true \
  -Dsonar.qualitygate.timeout=300

# Check the exit status of the docker run command
if [ $? -eq 0 ]; then
    echo ""
    echo "--------------------------------------------------------"
    echo "✅ Analysis complete! The Quality Gate status is PASSED."
    echo "--------------------------------------------------------"
else
    # The sonar-scanner returns a non-zero exit code if the Quality Gate fails.
    echo ""
    echo "--------------------------------------------------------"
    echo "⚠️ Analysis complete, but the Quality Gate FAILED."
    echo "--------------------------------------------------------"
    exit 1 # Exit with error status to signal a pipeline failure
fi

# --- Retrieve and display all issues from the SonarQube API ---
echo ""
echo "Fetching a full list of all issues for the project..."
echo ""

# Check for 'jq' dependency
if ! command -v jq &> /dev/null
then
    echo "⚠️ Warning: The 'jq' command is not found. Please install it to format the JSON output."
    echo "You can install it on Ubuntu with: sudo apt install jq"
    echo "You can get it on macOS with: brew install jq"
    echo "The raw API output will be printed below."
    echo ""
    curl -s -u "$SONAR_TOKEN": "$SONAR_HOST_URL/api/issues/search?projectKeys=$PROJECT_KEY&statuses=OPEN,CONFIRMED,REOPENED"
else
    # Use curl to call the API and jq to pretty-print the results.
    # We retrieve issues with OPEN, CONFIRMED, and REOPENED statuses.
    curl -s -u "$SONAR_TOKEN": "$SONAR_HOST_URL/api/issues/search?projectKeys=$PROJECT_KEY&statuses=OPEN,CONFIRMED,REOPENED" | \
    jq '.issues[] | {severity: .severity, type: .type, message: .message, component: .component, line: .line}'
fi

echo ""
echo "--------------------------------------------------------"
echo "View the full report and all issues at:"
echo "$SONAR_HOST_URL/dashboard?id=$PROJECT_KEY"
echo "--------------------------------------------------------"

