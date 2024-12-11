// add a server which runs on port 3000

const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World');
});

app.get('/audio', (req, res) => {
  // read the audio.aac file and send it as response
  res.sendFile(__dirname + '/output.aac');
});

app.get('/log', (req, res) => {
  // read the audio.aac file and send it as response
  res.sendFile(__dirname + '/ffmpeg.log');
});

app.get('/video', (req, res) => {
  // read the audio.aac file and send it as response
  res.sendFile(__dirname + '/output.mp4');
});

app.listen(3000, () => {
  console.log('Server is running on port 3000');
}
);