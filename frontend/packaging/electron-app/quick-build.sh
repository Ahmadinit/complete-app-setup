#!/bin/bash

# Quick rebuild script for testing
# Run this after making changes to main.js or other Electron code

set -e

PROJECT_ROOT="/Users/raheelmehar/Desktop/tcl-forecasting-psi-main"
ELECTRON_DIR="$PROJECT_ROOT/frontend/packaging/electron-app"

echo "🔄 Quick rebuild..."

cd "$ELECTRON_DIR"

# Clean and prep
rm -rf dist resources
mkdir -p resources/backend resources/app resources/data

# Copy files
echo "📦 Copying files..."
cp "$PROJECT_ROOT/backend/dist/psi-backend" resources/backend/
chmod +x resources/backend/psi-backend
cp -r "$PROJECT_ROOT/frontend/dist/"* resources/app/

# Build
echo "🏗️  Building Electron app..."
CSC_IDENTITY_AUTO_DISCOVERY=false npx electron-builder --mac --config electron-builder-x64.json

# Sign
echo "✍️  Signing app..."
cd dist/mac
xattr -cr "PSI Forecast System.app"
codesign --force --deep --sign - --entitlements "$ELECTRON_DIR/entitlements.mac.plist" "PSI Forecast System.app"

echo "✅ Done! Opening app..."
open "PSI Forecast System.app"
