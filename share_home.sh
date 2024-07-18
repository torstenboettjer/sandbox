#!/bin/bash

# Variables
NEW_REMOTE_REPO=""
NEW_BRANCH_NAME=""

# Prompt for the new remote repository name (in the format user/repo)
read -p "Enter the new remote repository name (user/repo): " NEW_REMOTE_REPO

# Create the new remote repository on GitHub
gh repo create "$NEW_REMOTE_REPO" --public

# Check if the repository was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to create the remote repository on GitHub."
    exit 1
fi

# Prompt for the new branch name
read -p "Enter the new branch name to create: " NEW_BRANCH_NAME

# Create the new branch locally
git branch "$NEW_BRANCH_NAME"

# Push the new branch to the new remote repository
git push "https://github.com/$NEW_REMOTE_REPO.git" "$NEW_BRANCH_NAME"

# Check if the branch was pushed successfully
if [ $? -ne 0 ]; then
    echo "Failed to push the new branch to the remote repository."
    exit 1
fi

# Unlink the local repository from the current origin
git remote remove origin

# Link the local repository with the new remote repository
git remote add origin "https://github.com/$NEW_REMOTE_REPO.git"

# Verify the new remote setup
git remote -v

echo "The local repository has been successfully linked to the new remote repository."
echo "New remote repository: https://github.com/$NEW_REMOTE_REPO.git"
echo "New branch created and pushed: $NEW_BRANCH_NAME"
