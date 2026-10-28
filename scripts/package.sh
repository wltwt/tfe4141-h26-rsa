#!/usr/bin/env bash
set -euo pipefail

# Go to root dir
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_dir"

if ! command -v zip >/dev/null 2>&1; then
    printf 'Error: install zip before running this script.\n' >&2
    exit 1
fi

rm -rf -- "$repo_dir/dist"
mkdir -p -- "$repo_dir/dist"
archive="$repo_dir/dist/rsa-alpha-$(date +%Y%m%d-%H%M%S).zip"
if [[ -e "$archive" ]]; then
    printf 'Error archive already exists: %s\n' "$archive" >&2
    exit 1
fi

# keep layout consistent
zip -r "$archive" README.md rtl sim constraints \
    scripts/create_project.tcl

printf '\nPackage ready: %s\n' "$archive"

