const { app, BrowserWindow } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');

// Determine if we're in development or production
const isDev = process.env.NODE_ENV === 'development' || !app.isPackaged;

// Path to the built frontend
function getFrontendPath() {
  if (isDev) {
    // Development: load from frontend dist
    return path.join(__dirname, '../../../dist/index.html');
  } else {
    // Production: load from app resources
    // In Electron Builder, extraResources are in app.asar.unpacked or resources
    const resourcesPath = process.resourcesPath || app.getAppPath();
    const appPath = path.join(resourcesPath, 'app', 'index.html');
    
    // Fallback: try different paths
    if (!fs.existsSync(appPath)) {
      const altPath = path.join(__dirname, '../app/index.html');
      if (fs.existsSync(altPath)) {
        return altPath;
      }
    }
    
    return appPath;
  }
}

// Path to backend executable
function getBackendPath() {
  if (isDev) {
    // Development: use Python directly
    return null; // Will use external backend in dev
  } else {
    // Production: use bundled executable
    const resourcesPath = process.resourcesPath || app.getAppPath();
    // Backend executable is in resources
    if (process.platform === 'darwin') {
      // macOS: executable is in app.asar.unpacked or resources
      const backendPath = path.join(resourcesPath, 'backend', 'psi-backend');
      console.log('Looking for backend at:', backendPath);
      if (fs.existsSync(backendPath)) {
        return backendPath;
      }
      // Fallback: try alternative path
      const altPath = path.join(__dirname, '../backend/psi-backend');
      console.log('Trying alternative path:', altPath);
      if (fs.existsSync(altPath)) {
        return altPath;
      }
    }
    console.error('Backend executable not found!');
    return null;
  }
}

// Path to database directory
function getDatabasePath() {
  if (isDev) {
    return path.join(__dirname, '../../../backend/data');
  } else {
    const resourcesPath = process.resourcesPath || app.getAppPath();
    return path.join(resourcesPath, 'data');
  }
}

let mainWindow;
let backendProcess = null;

function createWindow() {
  console.log('Creating main window...');
  console.log('isDev:', isDev);
  console.log('isPackaged:', app.isPackaged);
  
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1200,
    minHeight: 700,
    show: false,  // Don't show until ready
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      webSecurity: false,  // Disable for local file loading
      allowRunningInsecureContent: true
    },
    icon: path.join(__dirname, 'icons.icns'),
    titleBarStyle: 'hiddenInset',
    backgroundColor: '#ffffff'
  });

  // Open DevTools to see console logs
  mainWindow.webContents.openDevTools();

  // Show window when ready
  mainWindow.once('ready-to-show', () => {
    console.log('Window ready to show');
    mainWindow.show();
    mainWindow.focus();
  });

  // Log console messages from renderer
  mainWindow.webContents.on('console-message', (event, level, message, line, sourceId) => {
    console.log(`[Renderer] ${message}`);
  });

  // Load the frontend
  const frontendPath = getFrontendPath();
  console.log('Frontend path:', frontendPath);
  console.log('Frontend exists:', fs.existsSync(frontendPath));
  
  if (fs.existsSync(frontendPath)) {
    console.log('Loading frontend from file:', frontendPath);
    mainWindow.loadFile(frontendPath).then(() => {
      console.log('Frontend loaded successfully');
    }).catch(err => {
      console.error('Failed to load file:', err);
      // Fallback to dev server
      console.log('Falling back to dev server...');
      mainWindow.loadURL('http://localhost:5173');
    });
  } else {
    // Fallback: try loading from URL (for development)
    console.log('Frontend file not found, loading from dev server');
    mainWindow.loadURL('http://localhost:5173');
  }

  // Handle window closed
  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

// Check if backend is ready
async function waitForBackend(maxRetries = 30, delayMs = 1000) {
  const http = require('http');
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      await new Promise((resolve, reject) => {
        const req = http.get('http://127.0.0.1:8000/', (res) => {
          resolve();
        });
        req.on('error', reject);
        req.setTimeout(500);
      });
      console.log(`✅ Backend is ready! (attempt ${i + 1})`);
      return true;
    } catch (error) {
      console.log(`⏳ Waiting for backend... (attempt ${i + 1}/${maxRetries})`);
      await new Promise(resolve => setTimeout(resolve, delayMs));
    }
  }
  console.error('❌ Backend failed to start after', maxRetries, 'attempts');
  return false;
}

// Start backend server
async function startBackend() {
  const backendPath = getBackendPath();
  const dbPath = getDatabasePath();
  
  // Ensure database directory exists
  if (!fs.existsSync(dbPath)) {
    fs.mkdirSync(dbPath, { recursive: true });
    console.log(`📁 Created database directory: ${dbPath}`);
  }
  
  // Set environment variables for backend
  const env = {
    ...process.env,
    DATABASE_PATH: dbPath,
    DATABASE_URL: `sqlite:///${path.join(dbPath, 'psi_forecast.db')}`
  };
  
  if (!backendPath && !isDev) {
    console.error('Backend path not found, backend will not start');
    return false;
  }
  
  if (isDev) {
    // Development: assume backend is running externally
    console.log('Development mode - backend should be running externally');
    return await waitForBackend();
  } else {
    // Production: use bundled executable
    if (fs.existsSync(backendPath)) {
      console.log(`🚀 Starting backend from: ${backendPath}`);
      console.log(`💾 Database path: ${dbPath}`);
      
      backendProcess = spawn(backendPath, [], {
        shell: false,
        stdio: ['ignore', 'pipe', 'pipe'],
        env: env,
        detached: false
      });
      
      console.log(`📍 Backend process PID: ${backendProcess.pid}`);
    } else {
      console.error(`Backend executable not found at: ${backendPath}`);
      return false;
    }
  }
  
  // Handle backend output
  if (backendProcess) {
    backendProcess.stdout.on('data', (data) => {
      const output = data.toString();
      console.log(`[Backend] ${output.trim()}`);
    });
    
    backendProcess.stderr.on('data', (data) => {
      const error = data.toString();
      console.log(`[Backend] ${error.trim()}`);
    });
    
    backendProcess.on('error', (error) => {
      console.error(`❌ [Backend] Failed to start: ${error.message}`);
      if (mainWindow) {
        mainWindow.webContents.send('backend-error', error.message);
      }
    });
    
    backendProcess.on('exit', (code, signal) => {
      console.log(`🛑 [Backend] Process exited with code ${code}, signal ${signal}`);
      backendProcess = null;
    });
    
    // Wait for backend to be ready
    const isReady = await waitForBackend();
    return isReady;
  }
  
  return false;
}

// Stop backend server
function stopBackend() {
  if (backendProcess) {
    backendProcess.kill();
    backendProcess = null;
  }
}

app.whenReady().then(async () => {
  console.log('🎬 App is ready, starting backend...');
  const backendReady = await startBackend();
  
  if (backendReady) {
    console.log('✅ Backend is running, creating window...');
  } else {
    console.warn('⚠️  Backend failed to start, but continuing anyway...');
  }
  
  createWindow();
});

app.on('window-all-closed', () => {
  console.log('All windows closed');
  stopBackend();
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

app.on('before-quit', () => {
  console.log('App quitting, stopping backend...');
  stopBackend();
});