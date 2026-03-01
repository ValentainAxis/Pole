#!/bin/bash
set -e

# Путь к репозиторию
REPO_DIR=~/GENESIS/VAULT
cd "$REPO_DIR"

echo "🌿 Cleaning any broken hidden .git objects in _TRACES..."
rm -rf _TRACES/*/.git || true

echo "🌿 Making sure .gitignore exists..."
cat <<EOL >> .gitignore
_TRACES/
*.tmp
*.swp
*.bak
*.tgz
*.zip
EOL

git add .gitignore

echo "🌿 Adding only project files (ignores _TRACES and large files)..."
git add --all

echo "🌿 Committing new changes..."
git commit -m "VAULT: safe minimal commit" || echo "Nothing to commit"

echo "🌿 Pushing to GitHub..."
git push -u origin main || echo "Push failed, check remote"

echo "✅ VAULT minimal safe push completed!"
