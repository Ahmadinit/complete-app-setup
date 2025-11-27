```
tcl-forecasting-psi-main/
│
├── backend/                              # FastAPI Backend
│   ├── main.py                           # FastAPI main entry point with startup event
│   ├── standalone.py                     # PyInstaller entry point for bundled executable
│   ├── database.py                       # SQLite connection + auto-create tables
│   ├── models.py                         # SQLAlchemy models (User, Product, Sales, etc.)
│   ├── schemas.py                        # Pydantic models for API validation
│   ├── config.py                         # Settings (lead time, weights, DATABASE_URL)
│   ├── init_db.py                        # Manual database initialization script
│   ├── migrate_db.py                     # Database migration utilities
│   ├── requirements.txt                  # Python dependencies
│   ├── start_backend.bat                 # Windows backend launcher
│   ├── start_backend.ps1                 # PowerShell backend launcher
│   ├── README_START.md                   # Backend setup instructions
│   ├── SETUP_COMPLETE.md                 # Setup completion guide
│   ├── START_BACKEND.md                  # Backend startup guide
│   │
│   ├── data/                             # SQLite database directory
│   │   └── psi.db                        # Development database file
│   │
│   ├── routers/                          # API endpoints grouped by feature
│   │   ├── __init__.py
│   │   ├── auth.py                       # Authentication (login, user creation)
│   │   ├── dashboard.py                  # Dashboard stats and charts
│   │   ├── export.py                     # Excel/PDF export endpoints
│   │   ├── inventory.py                  # Inventory CRUD + PSI calculations
│   │   ├── models_api.py                 # Product model management
│   │   ├── monthly_plan.py               # Monthly planning endpoints
│   │   ├── purchase.py                   # Purchase order forecast + suggestions
│   │   ├── sales.py                      # Sales data input and forecasting
│   │   ├── settings_api.py               # System settings management
│   │   └── shipments.py                  # Shipment tracking (CKD, booking, etc.)
│   │
│   ├── utils/                            # Business logic and helper modules
│   │   ├── __init__.py
│   │   ├── calculations.py               # DOS, safety stock, inventory calculations
│   │   ├── export_excel.py               # Excel file generation
│   │   ├── export_pdf.py                 # PDF report generation
│   │   ├── forecast.py                   # Forecasting engine (weighted avg, ML)
│   │   ├── shipments_helper.py           # Shipment status management
│   │   └── weekly_po_generator.py        # Weekly PO generation logic
│   │
│   └── packaging/                        # Standalone build configuration
│       ├── README.md
│       ├── build_backend_macos.sh        # macOS backend build script
│       └── pyinstaller.spec              # PyInstaller specification file
│
│
├── frontend/                             # React + Vite Frontend
│   ├── index.html                        # HTML entry point
│   ├── package.json                      # Frontend dependencies
│   ├── package-lock.json                 # Dependency lock file
│   ├── vite.config.js                    # Vite build configuration (base: './')
│   │
│   ├── src/
│   │   ├── main.jsx                      # React entry point
│   │   ├── App.jsx                       # Main React app component
│   │   ├── index.css                     # Global styles
│   │   │
│   │   ├── components/                   # Reusable UI components
│   │   │   ├── AlertCard.jsx             # Alert/notification component
│   │   │   ├── Navbar.jsx                # Top navigation bar
│   │   │   └── Sidebar.jsx               # Side navigation menu
│   │   │
│   │   ├── pages/                        # Application screens/views
│   │   │   ├── Dashboard.jsx             # Main PSI dashboard with charts
│   │   │   ├── Inventory.jsx             # Inventory management interface
│   │   │   ├── Login.jsx                 # User authentication page
│   │   │   ├── Models.jsx                # Product model management
│   │   │   ├── PurchaseOrders.jsx        # Purchase order planning
│   │   │   ├── Sales.jsx                 # Sales data input and forecasting
│   │   │   ├── Settings.jsx              # System settings configuration
│   │   │   └── Shipments.jsx             # Shipment tracking interface
│   │   │
│   │   └── services/
│   │       └── api.js                    # Centralized Axios API calls
│   │
│   └── packaging/                        # Desktop app packaging
│       ├── BUILD_MACOS.md                # macOS build instructions
│       ├── BUILD_STANDALONE.md           # Standalone build guide
│       ├── PACKAGING_SUMMARY.md          # Packaging overview
│       ├── QUICK_START.md                # Quick start guide
│       ├── README.md                     # Packaging documentation
│       ├── build-instructions.md         # Build instructions
│       │
│       └── electron-app/                 # Electron desktop application
│           ├── main.js                   # Electron main process (window + backend)
│           ├── preload.js                # Electron preload script (security)
│           ├── package.json              # Electron dependencies
│           ├── package-lock.json         # Electron dependency lock
│           ├── package.json.backup       # Backup of original package.json
│           ├── icons.icns                # macOS app icon
│           ├── background.png            # DMG background image
│           ├── entitlements.mac.plist    # macOS entitlements (all permissions)
│           ├── electron-builder-quick.json    # Quick build config (arm64)
│           ├── electron-builder-x64.json      # x64 build configuration
│           ├── electron-builder.json          # Full build configuration
│           ├── quick-build.sh            # Fast rebuild script for testing
│           ├── temp-package.json         # Temporary package config
│           │
│           └── resources/                # Bundled app resources (created at build)
│               ├── app/                  # Frontend build output
│               │   ├── index.html
│               │   └── assets/           # JS/CSS bundles
│               │       ├── chart-vendor-*.js
│               │       ├── index-*.css
│               │       ├── index-*.js
│               │       ├── mui-vendor-*.js
│               │       └── react-vendor-*.js
│               ├── backend/              # Backend executable
│               │   └── psi-backend       # Compiled Python backend (74MB)
│               └── data/                 # Database directory (created at runtime)
│
│
├── build-macos-standalone.sh             # Complete standalone macOS build script
├── BUILD_STANDALONE_MACOS.md             # Standalone build guide
│
├── pyproject.toml                        # Python project configuration
├── pyrightconfig.json                    # Pyright type checker config
│
├── Documentation Files:
│   ├── README.md                         # This file - project overview
│   ├── ALL_FIXES_COMPLETE.md             # Summary of all fixes applied
│   ├── BUILD_FROM_WINDOWS.md             # Windows build instructions
│   ├── BUSINESS_LOGIC_MAPPING.md         # Business logic documentation
│   ├── COMPLETE_STEP_BY_STEP.md          # Complete setup guide
│   ├── CRUD_FIXES.md                     # CRUD operation fixes
│   ├── DASHBOARD_SALES_UPDATE.md         # Dashboard updates documentation
│   ├── FIXES_APPLIED.md                  # List of applied fixes
│   ├── FIXES_SUMMARY.md                  # Summary of bug fixes
│   ├── IMPLEMENTATION_SUMMARY.md         # Implementation overview
│   ├── NEXT_STEPS.md                     # Future development roadmap
│   ├── QUICK_BUILD_WINDOWS.md            # Quick Windows build guide
│   ├── STANDALONE_BUILD_SUMMARY.md       # Standalone build summary
│   ├── START_HERE_WINDOWS.md             # Windows setup start point
│   ├── STEP_BY_STEP_BUILD.md             # Step-by-step build instructions
│   └── WINDOWS_SETUP_CHECKLIST.md        # Windows setup checklist
│
└── Generated at Runtime (git-ignored):
    ├── venv/                             # Python virtual environment (dev)
    ├── backend/dist/                     # PyInstaller build output
    ├── backend/build/                    # PyInstaller temporary files
    ├── frontend/dist/                    # Vite build output
    ├── frontend/node_modules/            # Node.js dependencies
    ├── frontend/packaging/electron-app/dist/   # Electron build output
    │   ├── mac/                          # macOS x64 build
    │   │   └── PSI Forecast System.app   # Standalone macOS app
    │   └── mac-arm64/                    # macOS ARM64 build
    └── build-output/                     # Final DMG/installer files
```
