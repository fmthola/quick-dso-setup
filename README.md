SonarQube Local Setup for a Single Developer
This guide provides a simplified, script-based workflow to set up a local SonarQube server and perform code analysis on your projects. It is designed to be a quick and handy solution for individual developers.

Purpose
The primary purpose of this setup is to provide you with a personal instance of SonarQube for continuous code quality and security analysis. The included scripts automate key steps like starting the server, managing your security token, and running the analysis with a single command.

1. Prerequisites
Before you begin, ensure you have the following installed on your machine:

Docker: The scripts use Docker to run the SonarQube server in a container.

Python 3: Required to securely manage your SonarQube token using the keyring library.

sonar-scanner CLI: The command-line tool used to run the analysis. You can find installation instructions for your OS on the official SonarQube documentation.

2. Server Setup and Configuration
This section walks you through getting the SonarQube server up and running.

Step 2.1: Start the SonarQube Server
Use the provided shell script to pull the latest SonarQube image and run it as a detached container.

Navigate to the directory containing the setup_sonarqube.sh script.

Make the script executable:

chmod +x setup_sonarqube.sh

Run the script:

./setup_sonarqube.sh

After running the script, the SonarQube server will be accessible at http://localhost:9000. It may take a few minutes for the server to fully start.

Step 2.2: Initial Login and Token Generation
For security, the first time you log in, you will be required to change the default admin password. This is a one-time process.

Open your web browser and go to http://localhost:9000.

Log in using the default credentials:

Username: admin

Password: admin

You will be immediately prompted to change the password. Create a new, strong password and save it.

Once logged in, navigate to My Account > Security in the top right corner.

Under the Generate Tokens section, give your token a name (e.g., local-analysis) and click Generate.

Important: Copy the generated token immediately. This is the only time you will see it. We will store this token securely in the next step.

3. Store the SonarQube Token
The provided Python script uses the system's keyring to securely store your token, preventing it from being exposed in plain text files.

Make sure you have the keyring library installed:

pip install keyring

Navigate to the directory with the set_sonarqube_token.py script.

Run the script, and it will prompt you for the token you copied earlier.

python set_sonarqube_token.py

Paste the token when prompted.

You can verify that the token is stored correctly by running the get_sonarqube_token.py script:

python get_sonarqube_token.py

This script will print the stored token to the console.

4. Run the Code Analysis
The run_sonar_analysis.sh script automates the process of scanning your project and sending the results to your SonarQube server.

Step 4.1: Configure the Analysis Script
Open run_sonar_analysis.sh and set the following variables:

PROJECT_DIR: The path to the root of your source code directory.

PROJECT_NAME: A unique name for your project, which will be displayed in SonarQube.

Step 4.2: Run the Analysis
Make the script executable:

chmod +x run_sonar_analysis.sh

Run the script:

./run_sonar_analysis.sh

This script will automatically retrieve the token you stored in step 3 and use it for the analysis.

Step 4.3: View the Results
After the analysis completes, the script will output a link to the project dashboard in your local SonarQube instance. Click the link to view the detailed analysis results, including code smells, bugs, vulnerabilities, and code coverage.

5. Stopping the Server
To stop the SonarQube container when you are finished, use the following command:

docker stop sonarqube

This will stop the container, but it will not remove the data. The next time you run setup_sonarqube.sh, it will use the same data volume.

To completely remove the container and all associated data, use:

docker rm -v sonarqube

