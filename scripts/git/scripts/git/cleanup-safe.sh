#!/bin/bash

echo "WARNING: This will remove untracked files (SAFE CLEAN MODE)"
read -p "continue? (y/n): " ans

if [ "$ans" != "y" ]; then
  echo "Cancelled."
  exit 0
fi

if [ ! -d ".git" ]; then
  echo "Not a git repository!"
  exit 1
fi

# show what will be deleted first
echo "Preview of untracked files:"
git clean -nd

echo ""
read -p "Proceed with deletion? (y/n): " confirm

if [ "$confirm" = "y" ]; then
  git clean -fd
  echo "Cleanup completed."
else
  echo "Cancelled."
fi