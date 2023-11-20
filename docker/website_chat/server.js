const express = require('express');
const { exec } = require('child_process');
const bodyParser = require('body-parser');
const path = require('path');
const multer = require('multer');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
const PORT = 8099;

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'documents/'); // Files will be stored in the 'uploads' directory
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname); // Preserve the original file name
    }
});

const upload = multer({ storage: storage });

app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.post('/prompt', (req, res) => {
  const userMessage = req.body.message;

  // Forward the message to the external API
  try {
    const response = await axios.post('https://external-api.com/chat/{prompt}', {
      message: userMessage,
    });

    console.log('External API response:', response.data);
    res.status(200).send('Message sent successfully');
  } catch (error) {
    console.error('Error sending message to external API:', error.message);
    res.status(500).send('Internal Server Error');
  }
});

app.post('/assimilate', upload.single('file'), (req, res) => {
    const command = `genius-chatbot --assimilate documents`;
    exec(command, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error: ${error.message}`);
            return res.status(500).send('Internal Server Error');
        }
        if (stderr) {
            console.error(`Error: ${stderr}`);
            return res.status(500).send('Internal Server Error');
        }
        console.log(`Python script output: ${stdout}`);
        res.send(`Files Assimilated Successfully: ${stdout}`);
    });
});


app.get('/agents', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'agents.html'));
});
