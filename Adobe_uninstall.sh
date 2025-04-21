#!/bin/bash

# Check if there are enough command-line arguments (at least 2 required)
# Example usage: ./Adobe_uninstall.sh "Photoshop" "PHSP"
if [ "$#" -lt 2 ]; then
    echo "Usage: script.sh <app_name> <code>"
    exit 1
fi

# Check Mac processor architecture and set the corresponding platform identifier
# arm64 means Mac with M1/M2 chip, use macOS platform
# Otherwise (e.g., Intel chip) use osx10-64 platform
if [[ $(uname -m) == 'arm64' ]]; then
    chip="macOS"
else
    chip="osx10-64"
fi

# Set Adobe product name and product code
# app_name: Product name, e.g., "Photoshop"
# code: Product code, e.g., "PHSP" (each Adobe product has a unique code)
app_name=$2
code=$3

# Find all matching Adobe apps in the Applications directory
# -type d: Only search for directories
# -maxdepth 2: Search up to two directory levels
# 2>/dev/null: Ignore error messages
app_paths=$(find /Applications -type d -maxdepth 2 -name "Adobe ${app_name}*.app" 2>/dev/null)

# Check if matching apps are found
# -z checks if the string is empty
if [ -z "$app_paths" ]; then
    echo "No matching folder found for '${app_name}'."
    exit 0
fi

# Loop through all found Adobe installations
while IFS= read -r app_path; do
    # Get the application version number
    # mdls: Get file metadata
    # awk: Extract the version number within quotes
    version=$(mdls -name kMDItemVersion "$app_path" | awk -F '"' '{print $2}')
    # Extract the major version number (only the first number)
    # grep -o: Output only the matching part
    # ^[0-9]\+: Match one or more digits at the start
    major_version=$(echo "$version" | grep -o '^[0-9]\+')

    # Uninstall Adobe software
    # "/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup" --uninstall=1 --sapCode=${code} --baseVersion=${major_version}.0 --platform=${chip} --deleteUserPreferences=false
    "/Library/Application Support/Adobe/Adobe Desktop Common/HDBox/Setup" --uninstall=1 --sapCode=${code} --baseVersion=${major_version}.0 --platform=${chip} --deleteUserPreferences=false
    echo "Adobe ${app_name} with version ${version} found in folder '${app_path}' was deleted."
done <<< "$app_paths"
