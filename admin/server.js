const { createServer } = require('https');
const { parse } = require('url');
const next = require('next');
const fs = require('fs');
const path = require('path');

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

// Define paths to certificates (from root)
const certsDir = path.join(__dirname, '..', 'certs');
const httpsOptions = {
    key: fs.readFileSync(path.join(certsDir, 'server.key')),
    cert: fs.readFileSync(path.join(certsDir, 'server.cert')),
};

const PORT = 3000;

app.prepare().then(() => {
    createServer(httpsOptions, (req, res) => {
        const parsedUrl = parse(req.url, true);
        handle(req, res, parsedUrl);
    }).listen(PORT, (err) => {
        if (err) throw err;
        console.log(`> Ready on https://localhost:${PORT}`);
        console.log(`> Ready on https://15.207.36.26:${PORT}`);
    });
});
