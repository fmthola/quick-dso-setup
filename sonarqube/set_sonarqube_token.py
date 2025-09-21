#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
SONARQUBE TOKEN KEYRING SCRIPT

This script securely stores or retrieves your SonarQube analysis token 
using the cross-platform 'keyring' library. It will automatically use 
your operating system's native secret storage:
- macOS: Keychain Access
- Windows: Credential Manager
- Linux: Secret Service (e.g., GNOME Keyring)

--------------------------------------------------------------------------------

## 🔑 Instructions and Usage

### 1. Prerequisites
You must have Python installed and install the 'keyring' library:
$ pip install keyring

### 2. To Store the SonarQube Token
Run the script with the 'set' argument. It will securely prompt you 
for the token without showing the input on the screen.

$ python set_sonarqube_token.py set

   - Service Name: 'SonarQube'
   - Account Name: 'sonar_analysis_token'
   
### 3. To Retrieve the SonarQube Token
Run the script with the 'get' argument. This is primarily for testing
or to see how the retrieval function works. For actual use, you should 
call the 'get_token()' function inside another Python script 
to use the token as a variable.

$ python set_sonarqube_token.py get

--------------------------------------------------------------------------------
"""

import keyring
import getpass
import sys

# --- Configuration ---
# You can change these values, but keeping them consistent is key for retrieval.
SERVICE_NAME = "SonarQube"
USERNAME = "sonar_analysis_token"  # A generic username for the token

def set_token():
    """Prompts the user for the SonarQube token and securely stores it."""
    print(f"--- Setting SonarQube Token for Service: '{SERVICE_NAME}' ---")
    
    # Use getpass to securely prompt for the token without echoing
    token = getpass.getpass(f"Enter your SonarQube Token (will be hidden): ")
    
    if not token:
        print("Token cannot be empty. Aborting.")
        sys.exit(1)

    try:
        keyring.set_password(SERVICE_NAME, USERNAME, token)
        print(f"\n✅ SonarQube token successfully stored in the system keyring.")
        print(f"   (Service: {SERVICE_NAME}, Account: {USERNAME})")
    except Exception as e:
        print(f"\n❌ Error setting token: {e}")
        sys.exit(1)

def get_token():
    """Retrieves the SonarQube token from the keyring."""
    try:
        token = keyring.get_password(SERVICE_NAME, USERNAME)
        if token:
            print(f"Retrieved token successfully (first 5 chars): {token[:5]}*****")
            return token
        else:
            print(f"❌ Token not found for Service: '{SERVICE_NAME}' and Account: '{USERNAME}'.")
            return None
    except Exception as e:
        print(f"❌ Error retrieving token: {e}")
        return None

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Manage your SonarQube API token securely in the system keyring.")
    parser.add_argument('action', choices=['set', 'get'], help="The action to perform: 'set' to store the token, 'get' to retrieve (and print) it.")
    
    args = parser.parse_args()
    
    if args.action == 'set':
        set_token()
    elif args.action == 'get':
        retrieved_token = get_token()
        if retrieved_token:
            # You might use this retrieved_token in your SonarScanner command
            print(f"\nExample SonarScanner command (Token is retrieved as a variable):")
            print(f"sonar-scanner -Dsonar.host.url=... -Dsonar.token={retrieved_token}")
