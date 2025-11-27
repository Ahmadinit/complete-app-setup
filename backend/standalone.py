#!/usr/bin/env python3
"""
Standalone backend entry point for PyInstaller build.
This starts the FastAPI app with uvicorn embedded.
"""
import os
import sys
import multiprocessing

# Support for frozen executable
if getattr(sys, 'frozen', False):
    # Running in PyInstaller bundle
    bundle_dir = sys._MEIPASS
    os.chdir(bundle_dir)
else:
    # Running in normal Python
    bundle_dir = os.path.dirname(os.path.abspath(__file__))

# Add bundle directory to path
sys.path.insert(0, bundle_dir)

if __name__ == "__main__":
    # Required for PyInstaller multiprocessing
    multiprocessing.freeze_support()
    
    # Import and run uvicorn
    import uvicorn
    
    # Configuration
    host = os.environ.get("HOST", "127.0.0.1")
    port = int(os.environ.get("PORT", "8000"))
    
    print(f"Starting PSI Backend on {host}:{port}")
    print(f"Database path: {os.environ.get('DATABASE_PATH', 'data/')}")
    
    # Start the server
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        log_level="info",
        access_log=True
    )
