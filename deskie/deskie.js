"use strict";
const {
  app,
  BrowserWindow,
  Menu,
  BrowserView,
  ipcMain,
  screen,
} = require("electron");
/// const {autoUpdater} = require('electron-updater');
const { is } = require("electron-util");
const unhandled = require("electron-unhandled");
const debug = require("electron-debug");
const contextMenu = require("electron-context-menu");
const menu = require("./menu");
const packageJson = require("./package.json");
const { session } = require("electron");
const child_process = require("child_process");
let ffmpeg;
let browserView;

const environments = {
  stage: {
    hostname: "https://beta.veuelive.com",
    auth: "tlhd",
    session:
      "UTpGYFyg7921SjqqiGh4hShIeAiwnUs0d2onQP9YKDRe0fkS9TBH4iMOxHKF0okwH3dRoPRsi%2FKIyCLPxfepcTxnHY72ViP4TjxRtpmUB27NLJvZoSeEt%2FBGP%2FQNrezYiIdxLdQb6h59j76mW%2B%2BQu3HqPaUZG1YuulE9LKot7VoGnlbk4cCrZmpx16GM9wNu4QHG3s15w6SEjr9%2FfAGDdPxSKoMZyWhvZ9tM%2FGoyzHG2z4h4wfmP2k6HBEPrSXK2F1SX3ZwCVq1gg0fymYbCJw7Yr87t6crLKScNuocFsDfLYbETPg4LtPovQl0lEww9a%2F7KORprwuiSGUkUPf9Iw2Q8m4VvQAKR3tOVRvlxZlCtCyFLWfCiaGLNPgCZxVdX6yCVpdQ%3D--zaNdIhc1HULemYDZ--E3axLN%2F8KoptIHwAGtdQuQ%3D%3D",
  },
  localhost: {
    hostname: "http://localhost:3000",
    session:
      "xNQ6kt452i57bWwnpyNbdk34x8s0VcGZSyiEmfO6CrvjH%2Fi8pLJDm0Q%2BXzoDKkMBrKgmeAKDUNitZvPds%2B8%2BsTpa%2FT6IqVDfUGCN0co%2Fnw1OQH76u9wuQ2hU3tzuVZtL7H0DdLks1Kq2peGhF8qVBzypcuCueQPb%2BtCBnRdV%2FIpE78mFctXbGvCfvdnVFpJwCmpFT47IjBqne%2BSukQJSR11rJf9lx835GCVnU%2FBQe2zuDMgGKIZ8Rkg2T4PD9CiBM7CUvB0rXlYt5FTj05IoLIxzW6c%2FJLDp3TiFb6q3qwxbRJDWQDDANWB3vCpZUbwomfVg64EWGP4631a4xE5MJ0eJ5un%2FhVOoSL0mK6GkGF%2FxCUakAkiI0wHA%2Fu8aRLPBTuXUkMA%3D--hYn6HPzhiTpwkXiL--lb48%2FZWgIenmXh4VOsvCYA%3D%3D",
  },
};

const ENVIRONMENT = environments["localhost"];

unhandled();
debug();
contextMenu();

app.setAppUserModelId(packageJson.build.appId);

// Uncomment this before publishing your first version.
// It's commented out as it throws an error if there are no published versions.
// if (!is.development) {
// 	const FOUR_HOURS = 1000 * 60 * 60 * 4;
// 	setInterval(() => {
// 		autoUpdater.checkForUpdates();
// 	}, FOUR_HOURS);
//
// 	autoUpdater.checkForUpdates();
// }

// Prevent window from being garbage collected
let mainWindow;
let bounds = { x: 10, y: 80, width: 1080, height: 675 };
let windowSize = {
  width: 1630,
  height: 900,
};
let randomName = Math.random().toString(36).substring(7);

const createMainWindow = async () => {
  const browserWindow = new BrowserWindow({
    title: randomName,
    show: false,
    width: windowSize.width,
    height: windowSize.height,
    maximizable: false,
    closable: true,
    resizable: false,
    useContentSize: true,
    minimizable: false,
    webPreferences: {
      nodeIntegration: true,
    },
  });

  browserView = new BrowserView();

  // Now we want ot subscribe to the following events and send them to the main window
  [
    "did-start-loading",
    "did-stop-loading",
    "did-navigate",
    "will-navigate",
  ].forEach((eventName) => {
    console.log("Setup event monitoring for " + eventName);
    browserView.webContents.on(eventName, (event) => {
      console.log("Got event ", eventName, event);
      browserWindow.webContents.send(
        "browserView",
        eventName,
        browserView.webContents.getURL()
      );
    });
  });

  browserWindow.addBrowserView(browserView);

  app.on("login", (event, webContents, request, authInfo, callback) => {
    event.preventDefault();
    // popup a dialog to let the user enter a username/password
    // ...
    if (ENVIRONMENT["auth"]) {
      callback("", ENVIRONMENT["auth"]);
    }
  });

  browserWindow
    .loadURL(ENVIRONMENT["hostname"] + "/broadcasts")
    .then(() => console.log("loaded"));

  browserWindow.on("ready-to-show", () => {
    browserWindow.show();
    browserView.setBounds(bounds);
  });

  browserWindow.on("closed", () => {
    // Dereference the window
    // For multiple windows store them in an array
    app.quit();
  });

  return browserWindow;
};

// Prevent multiple instances of the app
if (!app.requestSingleInstanceLock()) {
  app.quit();
}

ipcMain.on("wakeup", (event, data) => {
  event.sender.send(
    "visible",
    bounds,
    screen.getPrimaryDisplay().workArea,
    windowSize,
    randomName
  );
});

ipcMain.on("stream", (event, data) => {
  if (ffmpeg) {
    console.log("Sending data to ffmpeg ", data.payload.length);
    ffmpeg.stdin.write(data.payload);
  } else {
    console.log("Got data, but no good instance of ffmpeg");
    event.sender.send("ffmpeg-error");
  }
});

ipcMain.handle("start", (_, data) => {
  const key = data.streamKey;

  const rtmpUrl = `rtmps://global-live.mux.com/app/${key}`;

  console.log("Streaming to ", rtmpUrl);

  ffmpeg = child_process.spawn("ffmpeg", [
    "-i",
    "-",

    // video codec config: low latency, adaptive bitrate
    "-c:v",
    "libx264",
    "-preset",
    "medium",
    "-tune",
    "zerolatency",

    // audio codec config: sampling frequency (11025, 22050, 44100), bitrate 64 kbits
    "-c:a",
    "aac",
    "-strict",
    "-2",
    "-ar",
    "44100",
    "-b:a",
    "64k",

    //force to overwrite
    "-y",

    // used for audio sync
    "-use_wallclock_as_timestamps",
    "1",
    "-async",
    "1",

    //'-filter_complex', 'aresample=44100', // resample audio to 44100Hz, needed if input is not 44100
    "-strict",
    "experimental",
    "-bufsize",
    "1000",
    "-f",
    "flv",

    rtmpUrl,
  ]);

  // Kill the WebSocket connection if ffmpeg dies.
  ffmpeg.on("close", (code, signal) => {
    console.log(
      "FFmpeg child process closed, code " + code + ", signal " + signal
    );
    ffmpeg = null;
  });

  // Handle STDIN pipe errors by logging to the console.
  // These errors most commonly occur when FFmpeg closes and there is still
  // data to write.f If left unhandled, the server will crash.
  ffmpeg.stdin.on("error", (e) => {
    console.log("FFmpeg STDIN Error", e);
  });

  // FFmpeg outputs all of its messages to STDERR. Let's log them to the console.
  ffmpeg.stderr.on("data", (data) => {
    console.log("FFmpeg STDERR:", data.toString());
  });
});

ipcMain.on("navigate", async (event, data) => {
  console.log(data);
  await browserView.webContents.loadURL(data);
  event.reply("DONE!");
});

app.on("second-instance", () => {
  if (mainWindow) {
    if (mainWindow.isMinimized()) {
      mainWindow.restore();
    }

    mainWindow.show();
  }
});

app.on("window-all-closed", () => {
  if (!is.macos) {
    app.quit();
  }
});

app.on("activate", () => {
  if (!mainWindow) {
    mainWindow = createMainWindow();
  }
});

(async () => {
  await app.whenReady();

  await session.defaultSession.cookies.set({
    url: ENVIRONMENT["hostname"],
    name: "_veue_session",
    value: ENVIRONMENT["session"],
  });

  Menu.setApplicationMenu(menu);
  mainWindow = await createMainWindow();

  // const favoriteAnimal = config.get('favoriteAnimal');

  // mainWindow.webContents.executeJavaScript(`document.querySelector('header p').textContent = 'Your favorite animal is ${favoriteAnimal}'`);
})();
