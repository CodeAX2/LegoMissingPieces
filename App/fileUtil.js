function getFilePath(file) {
    return file.path;
}

const { ipcRenderer } = require("electron");
ipcRenderer.on("directory-selected", (event, message) => {
    window.postMessage({ type: "directory-selected", data: { "directory": message["directory"] } }, "*")
});