#!/bin/bash

# Replace with your GitHub username
USERNAME="your-username"
# Replace with your personal access token
TOKEN="your-personal-access-token"
# Directory to clone repos into
CLONE_DIR="$HOME/Github"

# Create directory if it doesn't exist
mkdir -p "$CLONE_DIR"
cd "$CLONE_DIR"

# Get list of repos for user (handles pagination)
PAGE=1
while true; do
  REPOS=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/user/repos?per_page=100&page=$PAGE")
  
  # Break if no more repos
  if [ "$(echo "$REPOS" | jq length)" = "0" ]; then
    break
  fi
  
  # Clone each repo
  echo "$REPOS" | jq -r '.[].ssh_url' | while read -r repo_url; do
    repo_name=$(basename "$repo_url" .git)
    if [ ! -d "$repo_name" ]; then
      echo "Cloning $repo_name..."
      git clone "$repo_url"
    else
      echo "$repo_name already exists, skipping."
    fi
  done
  
  PAGE=$((PAGE+1))
done

echo "All repositories cloned to $CLONE_DIR" 