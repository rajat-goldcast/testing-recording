const puppeteer = require('puppeteer');
const { spawn } = require('child_process');
const fs = require('fs');
require('dotenv').config();

videoLink = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4"

magicLink = "https://events.dev.goldcast.io/auth/link/spoorthi@goldcast.io/sJ7NC4UbrmI?eventID=b7a67d9c-b0be-4b03-ad48-9448211ffbdd&shortId=186755"
stageLink = "https://events.dev.goldcast.io/e/b7a67d9c-b0be-4b03-ad48-9448211ffbdd/stage/broadcast/aac6f1a3-f786-4d56-999c-aab594055764?record_mode=true"

const FFMPEG_SCRIPTS = {
    "audio_only": "record_audio.sh",
    "full": "full_recording.sh",
    "mac_audio_only": "record_audio_mac.sh",
    "mac_full": "full_recording_mac.sh"
}

const runAudioRecorder = async () => {

    let scriptPath = process.env.HOST_OS == 'mac'? 'mac_audio_only':'audio_only'
    let script = FFMPEG_SCRIPTS[scriptPath];
    console.log('Running audio only script: ', script);
    ffmpeg = spawn(`./${script}`, { stdio: ['pipe', 'ignore', 'ignore'] });
    ffmpeg.on('error', (data) => {
        let strData = data.toString();
        let strDataFmt = strData.split('\n');
        console.log('audio only error: ', strDataFmt);
        throw new Error('Error while recording audio');
      });

    const closeAudioRecorder = async () => {
        console.log("Closing audio recorder");
        ffmpeg.stdin.write('q');
    }
    return closeAudioRecorder;
}

const runRecorder = async () => {
    let scriptPath = process.env.HOST_OS == 'mac'? 'mac_full':'full'
    let script = FFMPEG_SCRIPTS[scriptPath];
    console.log('Running script: ', script);
    ffmpeg = spawn(`./${script}`, { stdio: ['pipe', 'ignore', 'ignore'] });
    ffmpeg.on('error', (data) => {
        let strData = data.toString();
        let strDataFmt = strData.split('\n');
        console.log('recorder error: ', strDataFmt);
        throw new Error('Error while recording');
      });

    const closeRecorder = async () => {
        console.log("Closing recorder");
        ffmpeg.stdin.write('q');
    }
    return closeRecorder;
}

const navigateToVideo = async (url) => {
    console.log("host os: ", process.env.HOST_OS);
    let chrome_path = process.env.HOST_OS == 'mac'? '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome':'/usr/bin/google-chrome'
    console.log('Chrome path: ', chrome_path);
    const browser = await puppeteer.launch(
        {
            args: [
                '--no-sandbox',
                '--force-device-scale-factor=1.5',
                '--autoplay-policy=no-user-gesture-required',
                '--hide-scrollbars',
                '--disable-dev-shm-usage',
                '--window-position=0,0',
                '--window-size=1281,721',
                '--kiosk',
                '--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
            ],
            headless: false,
            defaultViewport: null,
            executablePath: chrome_path,
            ignoreDefaultArgs: ["--enable-automation"]
        }
    );
    const page = await browser.newPage();
    page.setDefaultNavigationTimeout(0);
    // await page.goto(url);
    await page.goto(magicLink, { waitUntil: "networkidle0" });
    await page.cookies();
    await page.goto(stageLink);
    page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    const closeBrowser = async () => {
        console.log("Closing browser");
        await browser.close();
    }

    return closeBrowser;
}

const startRecording = async () => { 
    if (fs.existsSync('output.aac')) {
        fs.unlink('output.aac', (err) => {
            if (err) {
                console.error(err)
                return
            }
        })
    }
    let VIDEO_DURATION = process.env.VIDEO_DURATION? parseInt(process.env.VIDEO_DURATION) * 1000: 900000;
    console.log("working with video duration: ", VIDEO_DURATION);

    let closeCallback = await navigateToVideo(videoLink);
    // let closeRecorder = await runRecorder();
    let closeAudioRecorder = await runAudioRecorder();
    setTimeout(async () => {
        await closeCallback();
        // await closeRecorder();
        await closeAudioRecorder();

    }, VIDEO_DURATION );
}

startRecording();