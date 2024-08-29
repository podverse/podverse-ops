#!/bin/bash

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the source and destination directories based on the script's location
SOURCE_DIR="$SCRIPT_DIR/../migrations"
DEST_DIR="$SCRIPT_DIR/../combined"
DEST_FILE="$DEST_DIR/init_database.sql"

# Create the destination directory if it does not exist
mkdir -p "$DEST_DIR"

# Create or clear the destination file
> "$DEST_FILE"

# Iterate over all .sql files in the source directory
for file in "$SOURCE_DIR"/*.sql; 
do
  # Append the contents of each .sql file to the destination file
  cat "$file" >> "$DEST_FILE"
  # Add a newline for separation
  echo "" >> "$DEST_FILE"
done

echo "All .sql files have been combined into $DEST_FILE"
