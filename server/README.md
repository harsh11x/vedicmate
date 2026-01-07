<<<<<<< HEAD
# Vedic Mate - AI-Powered Astrology Consultation App

A modern, secure, and spiritually enriching Flutter application that connects seekers with verified Vedic experts through advanced technology.

## Monorepo Structure

```
.
├── admin-panel/           # React admin (separate app)
├── server/                # Node/Express backend
└── lib/                   # Flutter mobile app (client + pandit)
```

## Run Backend (Node/Express)
=======
# Vedic Mate Backend Server

Backend server for Vedic Mate app with AI, wallet, payments, and real-time updates.

## Features

- ✅ **AI Chat Service** - Gemini/OpenAI integration with personality-based responses
- ✅ **Wallet Management** - Add/deduct money, transaction history
- ✅ **Real-time Updates** - WebSocket support for live balance updates
- ✅ **Chat Sessions** - Per-pandit chat session management
- ✅ **REST API** - Complete REST endpoints for all features

## Setup

### 1. Install Dependencies
>>>>>>> 3e0c63d (all build)

```bash
cd server
npm install
<<<<<<< HEAD
npm run dev
# Server on http://localhost:4000
```

## Run Admin Panel (React)

```bash 
cd admin-panel
npm install
npm run dev
# Admin on http://localhost:5173
```

## Run Flutter App (Mobile)

```bash
flutter pub get
flutter run
```

### Admin Login
- Email: `vedicmate2025@gmail.com`
- Password: `admin123`

> Note: The Flutter app no longer contains the admin panel. Use the React admin in `admin-panel/`.

## Features (Mobile)

- OTP-based and social login support
- Dual interface: Client and Pandit
- Digital Kundli generation and download
- Live and Remedies sections
- Video/Audio calls and encrypted chat (scaffold)
- Wallet, payments, ratings and reviews

## API Endpoints (Server)

- `GET /api/health` – health check
- `GET /api/settings` / `POST /api/settings` – platform settings
- `GET /api/pandits` / `POST /api/pandits` / `PUT /api/pandits/:id` / `POST /api/pandits/:id/block`
- `GET /api/bookings`
- `GET /api/live`

Integrate these endpoints from the Flutter app using `dio`/`http`, and from the Admin panel using `axios`.
=======
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and fill in your API keys:

```bash
cp .env.example .env
```

Edit `.env`:
```env
PORT=4000
GEMINI_API_KEY=your_gemini_api_key_here
# OR
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Get API Keys

**Gemini API Key:**
1. Go to https://makersuite.google.com/app/apikey
2. Sign in with Google
3. Create API key
4. Copy to `.env`

**OpenAI API Key (Alternative):**
1. Go to https://platform.openai.com/api-keys
2. Sign in and create API key
3. Copy to `.env`

### 4. Run Server

**Development:**
```bash
npm run dev
```

**Production:**
```bash
npm start
```

Server will run on `http://localhost:4000` (or your configured PORT).

## API Endpoints

### Health Check
```
GET /api/health
```

### AI Endpoints

**Get Welcome Message:**
```
POST /api/ai/welcome
Body: { "panditId": "ai_pandit_1" }
```

**Send Chat Message:**
```
POST /api/ai/chat
Body: {
  "message": "Tell me about my kundli",
  "history": [],
  "panditId": "ai_pandit_1"
}
```

### Wallet Endpoints

**Get Balance:**
```
GET /api/wallet/balance/:userId
```

**Add Money:**
```
POST /api/wallet/add
Body: {
  "userId": "user123",
  "amount": 1000,
  "type": "recharge",
  "description": "Wallet recharge"
}
```

**Deduct Money:**
```
POST /api/wallet/deduct
Body: {
  "userId": "user123",
  "amount": 50,
  "type": "chat",
  "description": "AI chat session"
}
```

**Get Transactions:**
```
GET /api/wallet/transactions/:userId?limit=50
```

### Chat Session Endpoints

**Get or Create Session:**
```
POST /api/chat/session
Body: {
  "userId": "user123",
  "panditId": "ai_pandit_1"
}
```

**Start Chat (with wallet check):**
```
POST /api/chat/start
Body: {
  "userId": "user123",
  "panditId": "ai_pandit_1",
  "sessionId": "optional_session_id"
}
```

**Get Session:**
```
GET /api/chat/session/:sessionId
```

## WebSocket Events

### Client → Server

**Join User Room:**
```javascript
socket.emit('join-user-room', userId);
```

**Request Balance:**
```javascript
socket.emit('request-balance', userId);
```

**Send Chat Message:**
```javascript
socket.emit('chat-message', {
  sessionId: 'session123',
  userId: 'user123',
  panditId: 'ai_pandit_1',
  message: 'Hello'
});
```

### Server → Client

**Balance Update:**
```javascript
socket.on('balance-update', (data) => {
  console.log('Balance:', data.balance);
});
```

**Chat Response:**
```javascript
socket.on('chat-response', (data) => {
  console.log('AI Response:', data.message);
});
```

**Chat Update:**
```javascript
socket.on('chat-update', (data) => {
  console.log('Messages:', data.messages);
});
```

## Deployment to AWS

### Option 1: AWS EC2

1. Launch EC2 instance (Ubuntu)
2. Install Node.js:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```
3. Clone repository and install dependencies
4. Set up PM2 for process management:
   ```bash
   npm install -g pm2
   pm2 start server.js --name vedicmate
   pm2 save
   pm2 startup
   ```
5. Configure security group to allow port 4000 (or your PORT)
6. Update Flutter app with EC2 IP address

### Option 2: AWS Elastic Beanstalk

1. Install EB CLI:
   ```bash
   pip install awsebcli
   ```
2. Initialize:
   ```bash
   eb init
   ```
3. Create environment:
   ```bash
   eb create vedicmate-env
   ```
4. Deploy:
   ```bash
   eb deploy
   ```

### Option 3: AWS Lambda + API Gateway

For serverless deployment, you'll need to refactor the code to work with Lambda functions.

## Environment Variables

- `PORT` - Server port (default: 4000)
- `HOST` - Server host (default: 0.0.0.0)
- `GEMINI_API_KEY` - Google Gemini API key
- `OPENAI_API_KEY` - OpenAI API key (alternative)

## Notes

- Currently uses in-memory storage (state object)
- For production, replace with MongoDB/PostgreSQL
- Add authentication middleware for secure endpoints
- Implement rate limiting
- Add logging (Winston/Morgan)
- Set up proper error handling

## Testing

Test the server:

```bash
# Health check
curl http://localhost:4000/api/health

# Get balance
curl http://localhost:4000/api/wallet/balance/user123

# Add money
curl -X POST http://localhost:4000/api/wallet/add \
  -H "Content-Type: application/json" \
  -d '{"userId":"user123","amount":1000}'

# AI welcome message
curl -X POST http://localhost:4000/api/ai/welcome \
  -H "Content-Type: application/json" \
  -d '{"panditId":"ai_pandit_1"}'
```
>>>>>>> 3e0c63d (all build)

