from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os
import sys
from config import settings

# Determine if running as bundled executable (PyInstaller)
if getattr(sys, 'frozen', False):
    # Running as compiled executable
    if sys.platform == 'darwin':  # macOS
        # Use app support directory for bundled app
        app_support = os.path.expanduser('~/Library/Application Support/PSI Forecast System')
        data_dir = os.path.join(app_support, 'data')
    elif sys.platform == 'win32':  # Windows
        app_data = os.path.expanduser('~/AppData/Roaming/PSI Forecast System')
        data_dir = os.path.join(app_data, 'data')
    else:  # Linux
        app_data = os.path.expanduser('~/.local/share/psi-forecast-system')
        data_dir = os.path.join(app_data, 'data')
    os.makedirs(data_dir, exist_ok=True)
    db_path = os.path.join(data_dir, 'psi.db')
    SQLALCHEMY_DATABASE_URL = f"sqlite:///{db_path}"
else:
    # Running as script (development or production)
    # Use environment variable for DATABASE_URL if available (production)
    # For Fly.io and other deployments, check for mounted volume
    db_path = os.getenv("DATABASE_URL", "/data/psi.db" if os.path.exists("/data") else "./data/psi.db")
    SQLALCHEMY_DATABASE_URL = db_path if db_path.startswith("postgresql") else f"sqlite:///{db_path}"
    
    # If using SQLite, create data directory
    if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
        current_dir = os.path.dirname(os.path.abspath(__file__))
        data_dir = os.path.join(current_dir, "data")
        os.makedirs(data_dir, exist_ok=True)

# Configure engine based on database type
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL, 
        connect_args={"check_same_thread": False}
    )
else:
    # PostgreSQL or other databases
    engine = create_engine(SQLALCHEMY_DATABASE_URL)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Export DATABASE_URL for migration script
DATABASE_URL = SQLALCHEMY_DATABASE_URL

def get_db():
    """Dependency for getting database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_tables():
    """Create all tables"""
    from models import Base
    Base.metadata.create_all(bind=engine)
