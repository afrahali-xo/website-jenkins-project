#!/usr/bin/env bash
set -euo pipefail
for file in index.html style.css script.js; do
  test -s "$file" || { echo "Missing or empty: $file"; exit 1; }
done
grep -qi '<html' index.html
grep -q 'style.css' index.html
grep -q 'script.js' index.html
echo 'Basic website checks passed.'
