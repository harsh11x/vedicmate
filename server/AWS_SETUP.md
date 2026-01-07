# AWS Backend Setup Guide

This guide explains how to configure the Vedic Mate Client App to connect to your AWS-hosted backend server.

## Prerequisites

- AWS EC2 instance running your Node.js backend server
- Backend server accessible via public IP or domain
- Security groups configured to allow HTTP/HTTPS traffic on port 4000 (or your configured port)

## Configuration Steps

### Option 1: Using Environment Variable (Recommended for Development)

When running the app, pass the AWS server URL:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_AWS_SERVER_IP:4000
```

For Android APK build:
```bash
flutter build apk --release --dart-define=API_BASE_URL=http://YOUR_AWS_SERVER_IP:4000
```

### Option 2: Direct Configuration (For Production)

Edit `lib/core/config/env.dart`:

```dart
class EnvConfig {
  // Replace with your AWS server IP/domain
  static const String apiBaseUrl = 'http://YOUR_AWS_SERVER_IP:4000';
  // Or use HTTPS with domain:
  // static const String apiBaseUrl = 'https://api.vedicmate.com';
}
```

### Option 3: Using Domain Name (Recommended for Production)

If you have a domain name pointing to your AWS server:

```dart
static const String apiBaseUrl = 'https://api.vedicmate.com';
```

## AWS Server Requirements

Your backend server (`server.js`) should:

1. **Listen on the correct port**: Default is 4000, but can be configured
2. **Enable CORS**: Allow requests from your Flutter app
3. **Handle API routes**: 
   - `/api/pandits` - Get list of pandits
   - `/api/bookings` - Handle bookings
   - `/api/wallets` - Wallet operations
   - `/api/live` - Live sessions
   - `/api/transactions` - Transaction history
   - `/api/payouts` - Payout management

## Security Considerations

1. **Use HTTPS in production**: Configure SSL certificate on your AWS server
2. **Firewall rules**: Only allow necessary ports (4000 for API, 443 for HTTPS)
3. **API Authentication**: Implement JWT tokens or API keys for secure communication
4. **Rate limiting**: Implement rate limiting to prevent abuse

## Testing Connection

1. Test your server is accessible:
   ```bash
   curl http://YOUR_AWS_SERVER_IP:4000/api/pandits
   ```

2. Check CORS headers are properly configured

3. Test from the app by checking network logs in Flutter DevTools

## Troubleshooting

### Connection Timeout
- Check AWS Security Groups allow inbound traffic on port 4000
- Verify server is running: `pm2 list` or `systemctl status your-service`
- Check server logs for errors

### CORS Errors
- Ensure backend has CORS middleware configured
- Allow origin: `*` for development or specific domain for production

### SSL Certificate Issues
- Use Let's Encrypt for free SSL certificates
- Configure nginx as reverse proxy for HTTPS

## Example AWS EC2 Setup

1. Launch EC2 instance (Ubuntu 22.04 LTS recommended)
2. Install Node.js and PM2:
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   sudo npm install -g pm2
   ```

3. Upload your `server.js` and run:
   ```bash
   pm2 start server.js --name vedicmate-api
   pm2 save
   pm2 startup
   ```

4. Configure Security Group:
   - Inbound: TCP 4000 from 0.0.0.0/0 (or specific IPs)
   - Outbound: All traffic

5. Get your public IP and update the app configuration

## Production Checklist

- [ ] Server running on AWS EC2
- [ ] Domain name configured (optional but recommended)
- [ ] SSL certificate installed (HTTPS)
- [ ] CORS properly configured
- [ ] API authentication implemented
- [ ] Rate limiting enabled
- [ ] Monitoring/logging set up
- [ ] Backup strategy in place
- [ ] App configured with production server URL
- [ ] Tested all API endpoints from app

