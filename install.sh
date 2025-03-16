#!/bin/zsh

# Define color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

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
  echo -e "Found ${BOLD}.stowignore${NC} with ${YELLOW}${#IGNORE_DIRS[@]}${NC} entries"
fi

# Detect the operating system and load system-specific stowignore file
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_SPECIFIC_IGNORE="$STOW_DIR/macos.stowignore"
  echo -e "Detected ${BOLD}macOS${NC} system"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
  OS_SPECIFIC_IGNORE="$STOW_DIR/windows.stowignore"
  echo -e "Detected ${BOLD}Windows${NC} system"
else
  OS_SPECIFIC_IGNORE="$STOW_DIR/linux.stowignore"
  echo -e "Detected ${BOLD}Linux${NC} system"
fi

# Load system-specific ignore file if it exists
if [[ -f "$OS_SPECIFIC_IGNORE" ]]; then
  echo -e "Loading system-specific ignore file: ${BOLD}$(basename "$OS_SPECIFIC_IGNORE")${NC}"
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" == \#* ]] && continue
    IGNORE_DIRS+=("$line")
  done < "$OS_SPECIFIC_IGNORE"
fi

# Add the .stowignore file itself and common VCS directories to the ignore list
IGNORE_DIRS+=(".git" ".svn" ".hg" "*.stowignore")

echo -e "\n${BOLD}Starting stow process for all directories...${NC}"
echo -e "Ignoring: ${YELLOW}${IGNORE_DIRS[@]}${NC}\n"

# Go through each directory
for dir in */; do
  # Remove trailing slash
  dir=${dir%/}
  
  # Check if directory is in the ignore list
  if [[ ${IGNORE_DIRS[(ie)$dir]} -le ${#IGNORE_DIRS} ]]; then
    echo -e "Skipping ${YELLOW}${dir}${NC} (in ignore list)"
    continue
  fi
  
  # Run stow
  echo -e "Stowing ${BLUE}${BOLD}${dir}${NC}..."
  stow "$dir"
  
  # Check if stow was successful
  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ Successfully stowed ${BOLD}${dir}${NC}"
  else
    echo -e "${RED}✗ Failed to stow ${BOLD}${dir}${NC}"
  fi
done

echo -e "\n${BOLD}All directories have been processed${NC}"

