#!/bin/sh

# Usage: ./makefile_macos_bundle.sh <input_executable> <output_app_bundle> <bundle_name>
# Example: ./makefile_macos_bundle.sh example-base example-base.app example-base

if [ $# -ne 3 ]; then
    echo "Usage: $0 <input_executable> <output_app_bundle> <bundle_name>"
    exit 1
fi

EXEC="$1"
APP_DIR="$2"
BUNDLE_NAME="$3"

# Check if the executable exists
if [ ! -f "$EXEC" ]; then
    echo "Error: Executable '$EXEC' does not exist."
    exit 1
fi

# Create bundle structure
if ! mkdir -p "${APP_DIR}/Contents/MacOS"; then
    echo "Error: Failed to create directory '${APP_DIR}/Contents/MacOS'."
    exit 1
fi

# Move the executable into the bundle
if ! mv "$EXEC" "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}"; then
    echo "Error: Failed to move '$EXEC' to '${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}'."
    exit 1
fi

# Ensure the executable has correct permissions
if ! chmod +x "${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}"; then
    echo "Error: Failed to set executable permissions on '${APP_DIR}/Contents/MacOS/${BUNDLE_NAME}'."
    exit 1
fi

# Create Info.plist
if ! cat > "${APP_DIR}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${BUNDLE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.${BUNDLE_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>1.0.0</string>
    <key>CFBundleName</key>
    <string>${BUNDLE_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
</dict>
</plist>
EOF
then
    echo "Error: Failed to create '${APP_DIR}/Contents/Info.plist'."
    exit 1
fi

echo "Successfully created ${APP_DIR}"
