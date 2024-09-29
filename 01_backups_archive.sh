#!/bin/bash

# Backup Script v1.0
# This script compresses and encrypts directories and saves an MD5 checksum for each backup.
# Author: Joan P.A. Kopernix
# License: MIT License
# Description: A mini script for archiving directory backups without pretensions.

# Function to compress and encrypt a single folder
backup_and_encrypt_folder() {
  local FOLDER="$1"
  local OUTPUT_DIR="$2"
  local DATE=$(date +"%Y%m%d") # Format date as YYYYMMDD
  local ARCHIVE_NAME="${OUTPUT_DIR}/${FOLDER}_${DATE}.tar.gz" # Archive name with date
  local ENCRYPTED_ARCHIVE="${ARCHIVE_NAME}.gpg" # Encrypted file name
  local CHECKSUM_FILE="${ARCHIVE_NAME}.md5" # MD5 checksum file

  echo "Processing folder: $FOLDER"

  # Create the .tar.gz compressed file
  tar -czf "$ARCHIVE_NAME" "$FOLDER"
  if [ $? -ne 0 ]; then
    echo "Error creating the .tar.gz file for folder $FOLDER."
    return 1
  fi

  # Encrypt the .tar.gz file using the provided GPG password
  echo "$GPG_PASSWORD" | gpg --batch --yes --passphrase-fd 0 --no-symkey-cache -c "$ARCHIVE_NAME"
  if [ $? -eq 0 ]; then
    echo "Encryption successful: ${ENCRYPTED_ARCHIVE}"
    rm -f "$ARCHIVE_NAME"
    
    # Generate and save MD5 checksum
    md5sum "${ENCRYPTED_ARCHIVE}" | awk '{ print $1 }' > "$CHECKSUM_FILE"
    echo "MD5 checksum saved: ${CHECKSUM_FILE}"
  else
    echo "Error during GPG encryption for file $ARCHIVE_NAME."
    return 1
  fi
}

# Check if an argument (specific folder name) is provided
TARGET_DIRECTORIES=()
OUTPUT_DIR="./backups"

while getopts ":d:o:" opt; do
  case $opt in
    d) TARGET_DIRECTORIES+=("$OPTARG");;  # Add folder to the list
    o) OUTPUT_DIR="$OPTARG";;             # Set the output directory
    \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
  esac
done

# Use current directory folders if none specified
if [ ${#TARGET_DIRECTORIES[@]} -eq 0 ]; then
  TARGET_DIRECTORIES=($(find . -maxdepth 1 -type d ! -name ".")) 
fi

# Verify if any directories were found
if [ ${#TARGET_DIRECTORIES[@]} -eq 0 ]; then
  echo "Error: No directories found to back up."
  exit 1
fi

# Create output directory if it does not exist
mkdir -p "$OUTPUT_DIR"

# Request GPG password once at the beginning
read -s -p "Enter the GPG password for encryption: " PASSWORD1
echo
read -s -p "Verify the GPG password: " PASSWORD2
echo

# Ensure passwords match
if [ "$PASSWORD1" != "$PASSWORD2" ]; then
  echo "Error: Passwords do not match."
  exit 1
fi

# Store the password in a variable for reuse
GPG_PASSWORD=$PASSWORD1

# Iterate through each folder and back it up
for FOLDER in "${TARGET_DIRECTORIES[@]}"; do
  CLEAN_FOLDER_NAME=$(basename "$FOLDER")
  backup_and_encrypt_folder "$CLEAN_FOLDER_NAME" "$OUTPUT_DIR"
  if [ $? -ne 0 ]; then
    echo "Failed to process folder: $CLEAN_FOLDER_NAME"
  fi
  echo "-----------------------------------------------------"
done

echo "All backups completed successfully in $OUTPUT_DIR."
