#!/bin/bash

# Mini script to create 5 folders and a text file inside each in the base directory.

# Create folders and files
for i in {1..5}; do
  # Folder name
  FOLDER_NAME="Folder_$i"
  
  # Create the folder in the base directory of the project
  mkdir -p "$FOLDER_NAME"

  # Create a text file inside the folder
  FILE_PATH="$FOLDER_NAME/file.txt"
  echo "This is the content of the file in $FOLDER_NAME" > "$FILE_PATH"
  
  # Confirmation message
  echo "Created folder: $FOLDER_NAME and file: $FILE_PATH"
done

echo "All folders and files have been successfully created in the base directory."

