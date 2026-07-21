const { createServer } = require('https');
const { parse } = require('url');
const next = require('next');
const fs = require('fs');
const path = require('path');
const httpProxy = require('http-proxy');

// Load env for AWS backend URL (production)
try {
  const envPath = path.join(__dirname, '.env.local');
  if (fs.existsSync(envPath)) {
    const env = fs.readFileSync(envPath, 'utf8');
    env.split('\n').forEach(line => {
      const m = line.match(/^([^#=]+)=(.*)$/);
      if (m) process.env[m[1].trim()] = m[2].trim();
    });
  }
} catch (_) {}

const dev = process.env.NODE_ENV !== 'production';
const app = next({ dev });
const handle = app.getRequestHandler();

// Define paths to certificates (from root)
const certsDir = path.join(__dirname, '..', 'certs');
const httpsOptions = {
    key: fs.readFileSync(path.join(certsDir, 'server.key')),
    cert: fs.readFileSync(path.join(certsDir, 'server.cert')),
};

const PORT = parseInt(process.env.PORT || '3000', 10);
const API_URL = process.env.NEXT_PUBLIC_API_BACKEND || process.env.NEXT_PUBLIC_API_URL?.replace(/\/api\/?$/, '') || 'http://localhost:3001';

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
            // Let Next.js handle or close
        }
    });

    server.listen(PORT, (err) => {
        if (err) throw err;
        console.log(`> Ready on https://localhost:${PORT}`);
        console.log(`> Ready on https://13.60.233.237:${PORT}`);
        console.log(`> Proxying /socket.io to ${API_URL}`);
    });
});
