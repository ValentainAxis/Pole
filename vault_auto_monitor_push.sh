#!/bin/bash
set -e

REPO_DIR=~/GENESIS/VAULT
cd "$REPO_DIR"

echo "🌿 Cleaning broken hidden .git objects in _TRACES..."
rm -rf _TRACES/*/.git || true

echo "🌿 Updating .gitignore..."
cat <<EOL >> .gitignore
_TRACES/
*.tmp
*.swp
*.bak
*.tgz
*.zip
EOL

git add .gitignore

echo "🌿 Initializing Git LFS for large files..."
git lfs install
git lfs track "*.tgz"
git lfs track "*.zip"
git add .gitattributes

echo "🌿 Checking repository status..."
git status

echo "🌿 Files tracked by Git LFS:"
git lfs ls-files || echo "No LFS files yet."

echo "🌿 Adding project files..."
git add --all

echo "🌿 Committing changes..."
git commit -m "VAULT: auto commit via monitor" || echo "Nothing to commit"

echo "🌿 Ensuring branch 'main' exists..."
git branch -M main

echo "🌿 Pushing to GitHub (force if needed)..."
git push -u origin main --force || git push -u origin main

echo "🌿 Cleaning git objects..."
git gc --prune=now --aggressive

echo "✅ VAULT auto-monitor push completed!"
