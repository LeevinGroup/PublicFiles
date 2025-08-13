#!/bin/bash

handle_exit() {
    local message="$1"
    read -p "$message"
    exit 1
}

# Check if NOT inside a valid Git repository, and exit early if true
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    handle_exit "Error: This directory is not inside a Git repository. Press enter to exit."
fi

# Normal flow if the directory is valid
echo "Valid Git repository detected."

git add .
git status

echo "Enter your commit message to confirm commit. Type 'n' or a blank message to cancel:"
read commit_message

if [ -z "$commit_message" ] || [ "$commit_message" = "n" ]; then
    handle_exit "Commit canceled by user. Press enter to exit."
fi

echo ""
echo "Committing changes with message: $commit_message"
echo ""
git commit -m "$commit_message"

echo ""
echo "Confirm commit and push changes to remote (y/n):"
read confirm_push

if [ "$confirm_push" != "y" ]; then
    git reset HEAD~  # Undo the commit if user cancels push
    handle_exit "Commit push canceled by user. Press enter to exit."
fi

git push
echo ""

# Get the list of committed files from the last commit
committed_files=$(git diff-tree --no-commit-id --name-only -r HEAD)

changed_files=""

while IFS= read -r file; do
  if [[ "$file" == $repo_path_prefix* ]]; then
    relative_path="${file#$repo_path_prefix}"
    url_path="${relative_path// /%20}"
    changed_files+="$base_url$url_path
"
  fi
done <<< "$committed_files"

if [ -n "$changed_files" ]; then
  echo "URLs of added/modified files in files/EmailSignatures:"
  echo -e "$changed_files"
else
  echo "No added or modified files in files/EmailSignatures to display URLs."
fi

echo ""
handle_exit "Commit pushed to remote. Press enter to exit."