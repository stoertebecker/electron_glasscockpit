// main.js

// Modules to control application life and create native browser window
const { app, BrowserWindow, ipcMain } = require('electron')
const path = require('node:path')
const net = require('net')

renderProcess = null

var socketClient = net.Socket()
socketClient.setEncoding('utf8')

const setSocketEvents = () => {
    socketClient.on('error', (error) => {
      console.log(error.message)
    })
    socketClient.on('data', (data) => {
      //console.log(data)
      renderProcess.webContents.send('dcsDataReceived', data)
    })
    socketClient.on('close', (hadError) => {
      if (hadError) {
        console.log('connection closed with transmission error');
      } else {
        console.log('connection closed');
      }
      setTimeout(trySocketConnection, 5000)
    }) 
}
setSocketEvents()


const connectCallback = () => {
  console.log('connection '+socketClient.readyState)
  socketClient.write('hello\r\n')
}
const trySocketConnection = () => {
  socketClient.off('connect', connectCallback)
  socketClient.connect(8666, '127.0.0.1', connectCallback)
  socketClient.setKeepAlive(true, 100)
}

const createWindow = () => {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    width: 1930,
    height: 1080,
    x: 2555,
    y: 0,
    frame: false,
    focusable: false,
    transparent: true,
    hasShadow: false,
    webPreferences: {
        nodeIntegration: true,
        contextIsolation: false,
    }
  })
  mainWindow.setAlwaysOnTop(true, 'screen-saver', 1)
  mainWindow.removeMenu()
  // and load the index.html of the app.
  mainWindow.loadFile('index.html')

  // Open the DevTools.
  mainWindow.webContents.openDevTools({mode:'undocked'})
  renderProcess = mainWindow
  trySocketConnection()
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Einige APIs können nur nach dem Auftreten dieses Events genutzt werden.
app.whenReady().then(() => {
  setTimeout(createWindow, 1000)

  app.on('activate', () => {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})


ipcMain.on('sendDcsCommand', (e, command) => {
    console.log('sendDcsCommand '+command);
    socketClient.write(command+'\r\n')
})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit()
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.