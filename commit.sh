#!/usr/bin/env bash

# Usage: ./commit.sh <project-root-path>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <project-root-path>" >&2
  exit 1
fi

# Check if Ollama is running
if ! curl -s --max-time 2 http://localhost:11434/api/tags > /dev/null 2>&1; then
  echo "Error: Ollama is not running. Please start Ollama first." >&2
  exit 1
fi

ROOT_DIR="$1"
cd "$ROOT_DIR" || { echo "Directory $ROOT_DIR not found"; exit 1; }

# Check if there are staged changes
if ! git diff --cached --quiet; then
  : # There are staged changes, continue
else
  echo "No staged changes found. Please run 'git add' first." >&2
  exit 1
fi

# Prepare diff
git diff --cached > changes.diff
FILE_PATH="$ROOT_DIR/changes.diff"

# Prepare request for Ollama
URL="http://localhost:11434/api/generate"

CONTENT=$(cat "$FILE_PATH")

USER_PROMPT="Generate a single-line conventional Git commit message in imperative mood based only on the diff below. 

Constraints:
- Only output the commit message, nothing else—no explanations, greetings, or formatting.
- Use imperative mood (e.g., 'Fix', 'Add', 'Refactor').
- Be concise and UNDER 70 characters.
- Focus on what changed and why.
- Ignore trivial formatting unless it's the main change.

Diff:
$CONTENT"

PAYLOAD=$(jq -n --arg prompt "$USER_PROMPT" --arg model "qwen2.5:7b" '
{
  model: $model,
  prompt: $prompt,
  stream: false
}')

RESPONSE=$(curl -s -X POST "$URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

# Extract just the message from Ollama response
COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.response')

rm $FILE_PATH

# Output and copy
echo -e "\nGenerated commit message:\n$COMMIT_MSG"
echo "$COMMIT_MSG" | pbcopy
echo -e "\nCommit message copied to clipboard."
