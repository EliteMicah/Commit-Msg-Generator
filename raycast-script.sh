#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Commit Msg
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 👾
# @raycast.argument1 { "type": "text", "placeholder": "Variable name (e.g., Project-Name)", "optional": true }

# Documentation:
# @raycast.description Generates a Commit Message before pushing
# @raycast.author Micah

# Source shell config to get environment variables
source ~/.zshrc

# Get the variable name from argument
VAR_NAME="$1"

# Use indirect expansion to get the value
PROJECT_PATH="${!VAR_NAME}"

if [[ -z "$PROJECT_PATH" ]]; then
  echo "Environment variable '$VAR_NAME' not found"
  exit 1
fi

# Run the commit script directly
# MODIFY PATH TO commit.sh
~/path/to/commit.sh "$PROJECT_PATH"
