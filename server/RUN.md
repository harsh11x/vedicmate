# Running the Server

## Quick Start

Just run:
```bash
node server.js
```

That's it! No npm scripts needed.

## First Time Setup

1. **Install dependencies** (one time only):
```bash
npm install
```

2. **Create `.env` file** in `server/` directory:
```env
PORT=4000
HOST=0.0.0.0
GEMINI_API_KEY=AIzaSyD5xwXaJbKIq_HzDSFhHY3ZaLQ_FvjS4Xw
```

3. **Run the server**:
```bash
node server.js
```

## Output

You should see:
```
🚀 Vedic Mate server running on 0.0.0.0:4000
📡 WebSocket server ready for real-time updates
🤖 AI Service: Gemini
```

## That's It!

The server will run on `http://localhost:4000`

No need for `npm run dev` or `npm start` - just use `node server.js` directly!

