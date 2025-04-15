#!/bin/bash
# Script to reset Git history to a single commit
# This script will create a new Git history with a single commit,
# effectively hiding all previous Git commits.

# Exit immediately if a command exits with a non-zero status
set -e

# Display a message explaining what the script does
echo "This script will reset your Git history to a single commit."
echo "WARNING: This will permanently remove all previous commit history from the remote repository."
echo "Make sure you have a backup if you need to preserve the history."
echo ""
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

# Optional: Commit any pending changes
echo "Checking for uncommitted changes..."
if [[ -n $(git status --porcelain) ]]; then
    echo "You have uncommitted changes. Please commit or stash them before proceeding."
    echo "Uncommitted changes:"
    git status --short
    exit 1
fi

# Get the current branch name
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"

# Create a new orphan branch (has no history)
echo "Creating new orphan branch 'temp_branch'..."
git checkout --orphan temp_branch

# Add all files
echo "Adding all files to the staging area..."
git add .

# Commit everything in one go
echo "Committing all files with a single commit..."
git commit -m "Initial public commit"

# Delete the old branch
echo "Deleting old '$CURRENT_BRANCH' branch..."
git branch -D $CURRENT_BRANCH

# Rename temp branch to the original branch name
echo "Renaming 'temp_branch' to '$CURRENT_BRANCH'..."
git branch -m $CURRENT_BRANCH

# Check if a remote repository is configured
echo "Checking for remote repository..."
if git remote -v | grep -q origin; then
    # Force push to remote
    echo "Force pushing to remote repository..."
    echo "WARNING: This will overwrite the remote history!"
    read -p "Continue with force push? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        git push -f origin $CURRENT_BRANCH
        echo "Force push completed successfully."
    else
        echo "Force push cancelled. You can manually push later with:"
        echo "git push -f origin $CURRENT_BRANCH"
    fi
else
    echo "No remote repository found. If you want to push to a remote repository, you can add one with:"
    echo "git remote add origin <repository-url>"
    echo "Then push with:"
    echo "git push -f origin $CURRENT_BRANCH"
fi

echo ""
echo "Git history has been reset to a single commit."
echo "You can verify with: git log --oneline"
