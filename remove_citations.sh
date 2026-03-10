#!/bin/bash
#
# Remove all [cite: <number>] patterns from .tex files
#

echo "Removing [cite: XXX] patterns from LaTeX files..."

# Find and process all .tex files
find . -type f -name "*.tex" -print0 | while IFS= read -r -d '' file; do
  echo "Processing: $file"
  sed -i 's/\[cite: [0-9]\+\]//g' "$file"
done

echo "Done! All [cite: XXX] instances have been removed."
