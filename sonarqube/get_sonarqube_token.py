#!/usr/bin/env python3
import keyring
import sys

SERVICE_NAME = "SonarQube"
USERNAME = "sonar_analysis_token"

try:
    token = keyring.get_password(SERVICE_NAME, USERNAME)
    if token:
        # Print only the token to stdout, which will be captured by the shell
        print(token)
    else:
        sys.stderr.write(f"ERROR: SonarQube token not found for service '{SERVICE_NAME}'.\n")
        sys.exit(1)
except Exception as e:
    sys.stderr.write(f"ERROR: Could not retrieve token from keyring: {e}\n")
    sys.exit(1)
