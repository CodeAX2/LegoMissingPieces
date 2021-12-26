const { ipcRenderer } = require("electron");

process.once("loaded", () => {
    window.addEventListener("message", e => {
        if (e.data.type == "select-directory") {
            ipcRenderer.send("select-directory");
        }
    });
});