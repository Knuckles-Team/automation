const express = require('express');
const { exec } = require('child_process');
const bodyParser = require('body-parser');
const path = require('path');
const multer = require('multer');

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
    const { parameter } = req.body;
    if (!parameter) {
        return res.status(400).send('Missing parameter');
    }

    const command = `genius-chatbot --prompt ${parameter} --json --mute-stream`;

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
        res.send(`Python script output: ${stdout}`);
    });
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

app.get('/health', (req, res) => {
    res.send(`200 Ok`);
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});