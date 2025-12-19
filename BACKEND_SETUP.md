# Backend Setup Guide - AWS Deployment

Complete guide to set up the Vedic Mate backend on AWS with AI, wallet, and real-time features.

## 🚀 Quick Start

### 1. Install Server Dependencies

```bash
cd server
npm install
```

### 2. Configure Environment

Create `.env` file in `server/` directory:

```bash
cp .env.example .env
```

Edit `.env`:
```env
PORT=4000
HOST=0.0.0.0
GEMINI_API_KEY=your_gemini_api_key_here
# OR
OPENAI_API_KEY=your_openai_api_key_here
```

### 3. Run Locally (Testing)

```bash
npm run dev
```

Server will run on `http://localhost:4000`

### 4. Deploy to AWS

#### Option A: AWS EC2 (Recommended)

1. **Launch EC2 Instance**
   - Choose Ubuntu 22.04 LTS
   - Instance type: t2.micro (free tier) or t3.small
   - Security Group: Allow port 4000 (HTTP) and 22 (SSH)

2. **Connect to EC2**
   ```bash
   ssh -i your-key.pem ubuntu@your-ec2-ip
   ```

3. **Install Node.js**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   node --version  # Should show v18.x or higher
   ```

4. **Install Git and Clone Repository**
   ```bash
   sudo apt-get update
   sudo apt-get install -y git
   git clone your-repo-url
   cd astroapp/server
   ```

5. **Install Dependencies**
   ```bash
   npm install
   ```

6. **Set Up Environment**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your API keys
   ```

7. **Install PM2 (Process Manager)**
   ```bash
   sudo npm install -g pm2
   pm2 start server.js --name vedicmate
   pm2 save
   pm2 startup  # Follow instructions to enable auto-start
   ```

8. **Check Status**
   ```bash
   pm2 status
   pm2 logs vedicmate
   ```

9. **Update Security Group**
   - Go to EC2 → Security Groups
   - Add inbound rule: Port 4000, Source: 0.0.0.0/0 (or your IP)

10. **Test Server**
    ```bash
    curl http://your-ec2-ip:4000/api/health
    ```

#### Option B: AWS Elastic Beanstalk

1. **Install EB CLI**
   ```bash
   pip install awsebcli
   ```

2. **Initialize**
   ```bash
   cd server
   eb init
   ```

3. **Create Environment**
   ```bash
   eb create vedicmate-env
   ```

4. **Set Environment Variables**
   ```bash
   eb setenv GEMINI_API_KEY=your_key PORT=4000
   ```

5. **Deploy**
   ```bash
   eb deploy
   ```

### 5. Update Flutter App

Update `lib/core/config/env.dart`:

```dart
static const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://YOUR_EC2_IP:4000', // Replace with your EC2 IP
);
```

Or run with environment variable:
```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_EC2_IP:4000
```

## 📡 API Endpoints

### Health Check
```
GET http://your-server:4000/api/health
```

### AI Endpoints

**Welcome Message:**
```bash
POST http://your-server:4000/api/ai/welcome
Content-Type: application/json

{
  "panditId": "ai_pandit_1"
}
```

**Chat Message:**
```bash
POST http://your-server:4000/api/ai/chat
Content-Type: application/json

{
  "message": "Tell me about my kundli",
  "history": [],
  "panditId": "ai_pandit_1"
}
```

### Wallet Endpoints

**Get Balance:**
```bash
GET http://your-server:4000/api/wallet/balance/user123
```

**Add Money:**
```bash
POST http://your-server:4000/api/wallet/add
Content-Type: application/json

{
  "userId": "user123",
  "amount": 1000,
  "type": "recharge",
  "description": "Wallet recharge"
}
```

**Deduct Money:**
```bash
POST http://your-server:4000/api/wallet/deduct
Content-Type: application/json

{
  "userId": "user123",
  "amount": 50,
  "type": "chat",
  "description": "AI chat session"
}
```

**Get Transactions:**
```bash
GET http://your-server:4000/api/wallet/transactions/user123?limit=50
```

### Chat Session Endpoints

**Get/Create Session:**
```bash
POST http://your-server:4000/api/chat/session
Content-Type: application/json

{
  "userId": "user123",
  "panditId": "ai_pandit_1"
}
```

**Start Chat:**
```bash
POST http://your-server:4000/api/chat/start
Content-Type: application/json

{
  "userId": "user123",
  "panditId": "ai_pandit_1"
}
```

## 🔌 WebSocket Connection

The server supports WebSocket for real-time updates.

**Flutter Connection:**
```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

final socket = IO.io('http://your-server:4000', <String, dynamic>{
  'transports': ['websocket'],
});

socket.onConnect((_) {
  print('Connected');
  socket.emit('join-user-room', 'user123');
});

socket.on('balance-update', (data) {
  print('Balance updated: ${data['balance']}');
});
```

## 🔒 Security Recommendations

1. **Use HTTPS** (Set up with Nginx reverse proxy or AWS Load Balancer)
2. **Add Authentication** (JWT tokens)
3. **Rate Limiting** (Use express-rate-limit)
4. **CORS Configuration** (Restrict to your app domains)
5. **Environment Variables** (Never commit .env file)
6. **Database** (Replace in-memory storage with MongoDB/PostgreSQL)

## 📊 Monitoring

### PM2 Monitoring
```bash
pm2 monit
pm2 logs vedicmate --lines 100
```

### Health Check Script
Create a cron job to check server health:
```bash
*/5 * * * * curl -f http://localhost:4000/api/health || pm2 restart vedicmate
```

## 🐛 Troubleshooting

### Server Not Starting
- Check Node.js version: `node --version` (should be 18+)
- Check port availability: `netstat -tulpn | grep 4000`
- Check logs: `pm2 logs vedicmate`

### AI Not Working
- Verify API keys in `.env`
- Check API quota/limits
- Review server logs for errors

### WebSocket Not Connecting
- Check firewall rules (port 4000)
- Verify CORS configuration
- Check browser console for errors

### Wallet Issues
- Verify user ID format
- Check transaction logs
- Review wallet service logs

## 📝 Next Steps

1. **Add Database** (MongoDB/PostgreSQL)
2. **Add Authentication** (JWT)
3. **Add Logging** (Winston)
4. **Add Rate Limiting**
5. **Set Up CI/CD** (GitHub Actions)
6. **Add Monitoring** (CloudWatch)
7. **Set Up Backup** (Automated database backups)

## 🎯 Production Checklist

- [ ] Environment variables configured
- [ ] API keys set up
- [ ] Database connected
- [ ] HTTPS enabled
- [ ] Authentication implemented
- [ ] Rate limiting configured
- [ ] Logging set up
- [ ] Monitoring enabled
- [ ] Backup strategy in place
- [ ] Security group configured
- [ ] Domain name configured (optional)

## 📞 Support

For issues or questions:
1. Check server logs: `pm2 logs vedicmate`
2. Check API health: `curl http://your-server:4000/api/health`
3. Review error messages in Flutter app console

---

**Your backend is now ready!** 🎉

Update your Flutter app's `env.dart` with your server IP and start using the backend services.

