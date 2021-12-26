const { app, BrowserWindow, dialog, ipcMain } = require("electron");
const path = require("path");

var win;

function createWindow() {
    win = new BrowserWindow({
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false,
            preload: path.join(__dirname, 'preload.js')
        }
    });

    win.loadFile("index.html");
}

function main() {
    createWindow();

    ipcMain.on("select-directory", async(event, arg) => {
        const result = await dialog.showOpenDialog(win, { properties: ["openDirectory"] });
        win.webContents.send("directory-selected", { "directory": result.filePaths[0] });
    });

}

app.whenReady().then(() => {
    main();
});