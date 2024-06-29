#!/bin/bash

# Usage: ./move.sh <source_directory>

# Parameters
SOURCE_DIR="$1"
DUPLICATE_DIR="duplicates"
DB_FILE="/tmp/image_hashes.db"

# Check if source directory parameter is provided
if [ -z "$SOURCE_DIR" ]; then
    echo "Usage: ./move.sh <source_directory>"
    exit 1
fi

# Ensure the duplicate directory exists
mkdir -p "$DUPLICATE_DIR"

# Create SQLite database and table
sqlite3 $DB_FILE "CREATE TABLE IF NOT EXISTS images (hash TEXT, filepath TEXT);"

# Clear the database table
sqlite3 $DB_FILE "DELETE FROM images;"

# Find all images and calculate their MD5 hashes
find "$SOURCE_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -exec md5sum {} + | while read -r hash filepath; do
    # Insert the hash and file path into the database
    sqlite3 $DB_FILE "INSERT INTO images (hash, filepath) VALUES ('$hash', '$filepath');"
done

# Query for duplicate hashes and process each group
sqlite3 -separator '|' $DB_FILE "SELECT hash, group_concat(filepath, '|') AS filepaths FROM images GROUP BY hash HAVING COUNT(*) > 1;" | while IFS='|' read -r hash filepaths; do
    # Split filepaths into an array
    IFS='|' read -r -a filepath_array <<< "$filepaths"

    # Move the first file in the array to duplicates directory
    mv "${filepath_array[0]}" "$DUPLICATE_DIR/"
    echo "Moved duplicate image: ${filepath_array[0]}"

    # Print messages for each remaining file in the array
    for ((i = 1; i < ${#filepath_array[@]}; i++)); do
        echo "  Duplicate of: ${filepath_array[i]}"
    done
done

# Clean up
rm $DB_FILE

echo "Duplicate scan and move completed."
