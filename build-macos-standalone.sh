#!/bin/bash

# =============================================================================
# PSI Forecasting System - Complete Standalone macOS Build Script
# =============================================================================
# This script builds a complete standalone DMG for macOS including:
# - Backend Python executable (PyInstaller)
# - Frontend React app (Vite)
# - Electron wrapper
# - SQLite database
# - Everything packaged into a single .dmg file
# 
# NO CODE SIGNING OR NOTARIZATION - For personal use only
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
ELECTRON_DIR="$FRONTEND_DIR/packaging/electron-app"
BUILD_DIR="$PROJECT_ROOT/build-output"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  PSI Forecasting System - macOS Standalone Builder${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# =============================================================================
# STEP 1: Clean previous builds
# =============================================================================
echo -e "${YELLOW}[1/6] 🧹 Cleaning previous builds...${NC}"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
rm -rf "$BACKEND_DIR/dist"
rm -rf "$BACKEND_DIR/build"
rm -rf "$FRONTEND_DIR/dist"
rm -rf "$ELECTRON_DIR/dist"
rm -rf "$ELECTRON_DIR/build"
echo -e "${GREEN}✓ Cleaned${NC}"
echo ""

# =============================================================================
# STEP 2: Build Backend with PyInstaller
# =============================================================================
echo -e "${YELLOW}[2/6] 🔨 Building backend executable...${NC}"
cd "$BACKEND_DIR"

# Check if venv exists
if [ ! -d "venv" ]; then
    echo -e "${BLUE}Creating virtual environment...${NC}"
    python3.10 -m venv venv || python3 -m venv venv
fi

# Activate venv
source venv/bin/activate

# Install dependencies
echo -e "${BLUE}Installing backend dependencies...${NC}"
pip install --quiet --upgrade pip
pip install --quiet -r requirements.txt
pip install --quiet pyinstaller

# Build backend
echo -e "${BLUE}Building backend executable with PyInstaller...${NC}"
pyinstaller --clean packaging/pyinstaller.spec

# Verify build
if [ ! -f "dist/psi-backend" ]; then
    echo -e "${RED}❌ Backend build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Backend built successfully ($(du -h dist/psi-backend | cut -f1))${NC}"
deactivate
echo ""

# =============================================================================
# STEP 3: Build Frontend with Vite
# =============================================================================
echo -e "${YELLOW}[3/6] ⚛️  Building frontend...${NC}"
cd "$FRONTEND_DIR"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}Installing frontend dependencies...${NC}"
    npm install
fi

# Build frontend
echo -e "${BLUE}Building React app with Vite...${NC}"
npm run build

# Verify build
if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Frontend build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Frontend built successfully${NC}"
echo ""

# =============================================================================
# STEP 4: Prepare Electron App
# =============================================================================
echo -e "${YELLOW}[4/6] 📦 Preparing Electron app...${NC}"
cd "$ELECTRON_DIR"

# Create directories
mkdir -p resources/backend
mkdir -p resources/app
mkdir -p resources/data

# Copy backend executable
echo -e "${BLUE}Copying backend executable...${NC}"
cp "$BACKEND_DIR/dist/psi-backend" resources/backend/psi-backend
chmod +x resources/backend/psi-backend

# Copy frontend build
echo -e "${BLUE}Copying frontend build...${NC}"
cp -r "$FRONTEND_DIR/dist/"* resources/app/

# Create empty database directory
echo -e "${BLUE}Creating database directory...${NC}"
mkdir -p resources/data

# Update package.json to disable code signing
echo -e "${BLUE}Configuring Electron Builder (no code signing)...${NC}"
cat > temp-package.json << 'EOF'
{
    "name": "psi-forecast-system",
    "version": "1.0.0",
    "description": "PSI (Purchase, Sales, Inventory) Forecasting System",
    "main": "main.js",
    "author": "PSI Forecast Team",
    "scripts": {
        "start": "electron .",
        "build": "electron-builder --mac --config electron-builder.json"
    },
    "devDependencies": {
        "electron": "^28.0.0",
        "electron-builder": "^24.9.1"
    }
}
EOF

# Create electron-builder config without code signing
cat > electron-builder.json << 'EOF'
{
    "appId": "com.psi.forecast.system",
    "productName": "PSI Forecast System",
    "directories": {
        "output": "dist",
        "buildResources": "build"
    },
    "files": [
        "main.js",
        "preload.js",
        "package.json"
    ],
    "extraResources": [
        {
            "from": "resources/backend",
            "to": "backend",
            "filter": ["**/*"]
        },
        {
            "from": "resources/app",
            "to": "app",
            "filter": ["**/*"]
        },
        {
            "from": "resources/data",
            "to": "data",
            "filter": ["**/*"]
        }
    ],
    "mac": {
        "category": "public.app-category.business",
        "target": [
            {
                "target": "dmg",
                "arch": ["x64", "arm64"]
            }
        ],
        "identity": null,
        "hardenedRuntime": false,
        "gatekeeperAssess": false,
        "entitlements": "entitlements.mac.plist",
        "entitlementsInherit": "entitlements.mac.plist",
        "type": "distribution"
    },
    "dmg": {
        "title": "PSI Forecast System",
        "background": null,
        "contents": [
            {
                "x": 410,
                "y": 190,
                "type": "link",
                "path": "/Applications"
            },
            {
                "x": 130,
                "y": 190,
                "type": "file"
            }
        ],
        "window": {
            "width": 540,
            "height": 380
        },
        "sign": false
    },
    "afterSign": null,
    "afterPack": null
}
EOF

# Backup original package.json
if [ -f "package.json" ]; then
    cp package.json package.json.backup
fi

cp temp-package.json package.json

echo -e "${GREEN}✓ Electron app prepared${NC}"
echo ""

# =============================================================================
# STEP 5: Install Electron Dependencies
# =============================================================================
echo -e "${YELLOW}[5/6] 📥 Installing Electron dependencies...${NC}"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    npm install
else
    echo -e "${BLUE}Dependencies already installed${NC}"
fi

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# =============================================================================
# STEP 6: Build DMG
# =============================================================================
echo -e "${YELLOW}[6/6] 🚀 Building DMG package...${NC}"

# Set environment variable to skip code signing
export CSC_IDENTITY_AUTO_DISCOVERY=false
export CSC_LINK=""
export CSC_KEY_PASSWORD=""

# Build
echo -e "${BLUE}Running Electron Builder...${NC}"
npm run build

# Check if DMG was created
DMG_FILE=$(find dist -name "*.dmg" -type f | head -n 1)

if [ -z "$DMG_FILE" ]; then
    echo -e "${RED}❌ DMG build failed!${NC}"
    exit 1
fi

# Move DMG to build output directory
DMG_NAME=$(basename "$DMG_FILE")
mv "$DMG_FILE" "$BUILD_DIR/$DMG_NAME"

# Restore original package.json
if [ -f "package.json.backup" ]; then
    mv package.json.backup package.json
fi

# Clean up temp files
rm -f temp-package.json electron-builder.json

# Get file size
DMG_SIZE=$(du -h "$BUILD_DIR/$DMG_NAME" | cut -f1)

echo ""
echo -e "${GREEN}✓ DMG built successfully!${NC}"
echo ""

# =============================================================================
# Build Complete!
# =============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Build Complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}📦 DMG Package:${NC} $BUILD_DIR/$DMG_NAME"
echo -e "${GREEN}💾 Size:${NC} $DMG_SIZE"
echo ""
echo -e "${YELLOW}Installation Instructions:${NC}"
echo -e "  1. Open the DMG file"
echo -e "  2. Drag 'PSI Forecast System' to Applications folder"
echo -e "  3. Open from Applications (Right-click → Open first time)"
echo -e "  4. If blocked by Gatekeeper, go to System Settings → Privacy & Security"
echo -e "     and click 'Open Anyway'"
echo ""
echo -e "${BLUE}Note: This is an unsigned app for personal use only${NC}"
echo ""
