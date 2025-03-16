#!/bin/zsh

# Set the stow directory to the current directory
STOW_DIR=$(pwd)
# Initialize an empty array for directories to ignore
IGNORE_DIRS=()

# Check if .stowignore exists and read it
if [[ -f "$STOW_DIR/.stowignore" ]]; then
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue
    IGNORE_DIRS+=("$line")
  done < "$STOW_DIR/.stowignore"
  echo "Found .stowignore with ${#IGNORE_DIRS[@]} entries"
fi

# Add the .stowignore file itself and common VCS directories to the ignore list
IGNORE_DIRS+=(".git" ".svn" ".hg")

echo "Starting stow process for all directories..."
echo "Ignoring: ${IGNORE_DIRS[@]}"

# Go through each directory
for dir in */; do
  # Remove trailing slash
  dir=${dir%/}
  
  # Check if directory is in the ignore list
  if [[ ${IGNORE_DIRS[(ie)$dir]} -le ${#IGNORE_DIRS} ]]; then
    echo "Skipping $dir (in ignore list)"
    continue
  fi
  
  # Run stow
  echo "Stowing $dir..."
  stow "$dir"
  
  # Check if stow was successful
  if [[ $? -eq 0 ]]; then
    echo "✓ Successfully stowed $dir"
  else
    echo "✗ Failed to stow $dir"
  fi
done

echo "All directories have been processed"

