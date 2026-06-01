#!/bin/bash

echo "WARNING: This will reset local changes"
read -p "continue? (y/n): " ans

if [ "$ans" = "y" ]; then
  git checkout main
  git reset --hard origin/main
  git clean -fd
  git pull origin main
fi## Ops Commands
ดูที่ scripts/git/reset-safe.sh