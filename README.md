# Image Duplicate Finder and Mover

This Bash script (`scan.sh`) is designed to scan a specified directory for image files (JPEG, PNG, GIF) and move duplicates to a separate directory (`duplicates`). It uses SQLite for storing image hashes to efficiently identify and handle duplicates.

## Usage

Ensure you have SQLite3 installed on your system before running the script.


```bash
./scan.sh <source_directory>
```


