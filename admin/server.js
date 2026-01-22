const { createServer } = require('https');
const { parse } = require('url');
const next = require('next');
const fs = require('fs');
const path = require('path');

const httpProxy = require('http-proxy');

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
const API_URL = 'http://localhost:3001';

const proxy = httpProxy.createProxyServer({
    target: API_URL,
    changeOrigin: true,
    ws: true
});

app.prepare().then(() => {
    const server = createServer(httpsOptions, (req, res) => {
        const parsedUrl = parse(req.url, true);
        const { pathname } = parsedUrl;

        // Proxy /socket.io and /api requests manually
        if (pathname.startsWith('/socket.io') || pathname.startsWith('/api')) {
            return proxy.web(req, res);
        }

        handle(req, res, parsedUrl);
    });

    // Handle WebSocket Upgrades
    server.on('upgrade', (req, socket, head) => {
        const parsedUrl = parse(req.url, true);
        const { pathname } = parsedUrl;

        if (pathname.startsWith('/socket.io')) {
            proxy.ws(req, socket, head);
        } else {
            // Let Next.js handle (if needed, mostly HMR in dev) or close
            // But custom server doesn't usually handle socket upgrades unless we pass them
            // to the next dev server. In prod, we only care about socket.io
            // socket.destroy();
        }
    });

    server.listen(PORT, (err) => {
        if (err) throw err;
        console.log(`> Ready on https://localhost:${PORT}`);
        console.log(`> Ready on https://15.207.36.26:${PORT}`);
        console.log(`> Proxying /socket.io to ${API_URL}`);
    });
});
