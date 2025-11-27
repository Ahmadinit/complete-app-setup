# Build Standalone macOS App - Quick Guide

## Prerequisites

1. **macOS** (tested on macOS 10.15+)
2. **Python 3.10** installed
3. **Node.js** (v16 or higher) and npm
4. **Xcode Command Line Tools** (for native builds)

## One-Command Build

```bash
./build-macos-standalone.sh
```

This single script will:
- ✅ Build the Python backend into a standalone executable
- ✅ Build the React frontend
- ✅ Package everything with Electron
- ✅ Create a DMG installer (unsigned, for personal use)

## Build Output

The final DMG will be in: `build-output/PSI Forecast System-*.dmg`

## Installation

1. Open the DMG file
2. Drag "PSI Forecast System" to Applications
3. **First launch**: Right-click → Open (to bypass Gatekeeper)
4. If prompted, go to System Settings → Privacy & Security → Click "Open Anyway"

## What's Included

The standalone app includes:
- 🔧 Backend (FastAPI + SQLite) - fully embedded
- 🎨 Frontend (React + Vite) - built and bundled
- 💾 Database - created automatically in user data
- 📦 All dependencies - no external installations needed

## Build Time

Expect 5-10 minutes for first build (downloads dependencies).
Subsequent builds: 2-3 minutes.

## Troubleshooting

### Build fails at backend step
```bash
cd backend
source venv/bin/activate
pip install -r requirements.txt
pip install pyinstaller
```

### Build fails at frontend step
```bash
cd frontend
npm install
npm run build
```

### Build fails at Electron step
```bash
cd frontend/packaging/electron-app
npm install
```

## Notes

- **No code signing**: This is for personal use only
- **Gatekeeper warning**: Normal for unsigned apps - use Right-click → Open
- **Database location**: Stored in app's Resources folder
- **Portable**: All data stays within the app bundle

## Clean Rebuild

To start fresh:
```bash
rm -rf build-output
rm -rf backend/dist backend/build
rm -rf frontend/dist
rm -rf frontend/packaging/electron-app/dist
./build-macos-standalone.sh
```
