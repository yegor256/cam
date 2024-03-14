#!/bin/bash

# List all Java files in the repo history
git log --name-only --pretty=format: | grep '\.java$' | sort | uniq > all_java_files.txt

# Create a file to store the final counts
echo "" > siblings_count.txt

# Iterate over each Java file and count how many times it appears with others
while read file; do
  echo "Analyzing $file..."
  # Count how many times each file appears in the same commit as the current file
  git log --pretty=format:"%H" --name-only | grep -B1 $file | grep '\.java$' | sort | uniq -c | sort -rn > temp_count.txt
  echo "$file: " >> siblings_count.txt
  cat temp_count.txt >> siblings_count.txt
  echo "" >> siblings_count.txt
done <all_java_files.txt

echo "Analysis complete. Check siblings_count.txt for results."
