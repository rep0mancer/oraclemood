#!/bin/bash

# Increment the build number (CFBundleVersion) in the Info.plist file. This is
# useful for CI pipelines that want to automatically bump the build number for
# each commit. The script uses `PlistBuddy`, which is available on macOS.

set -euo pipefail

INFO_PLIST="${1:-OracleLightApp/Info.plist}"

if [ ! -f "$INFO_PLIST" ]; then
  echo "Info.plist not found at $INFO_PLIST"
  exit 1
fi

current=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST" 2>/dev/null || echo "0")
next=$((current + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $next" "$INFO_PLIST"
echo "Incremented build number to $next"