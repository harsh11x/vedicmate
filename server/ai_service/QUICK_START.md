# Quick Start Guide - Vedic Mate AI Service

## 🚀 Quick Setup (5 minutes)

### 1. Install Python 3.9+

```bash
python3 --version  # Should be 3.9 or higher
```

### 2. Navigate to AI Service Directory

```bash
cd ai_service
```

### 3. Run Setup Script

```bash
chmod +x start.sh
./start.sh
```

This will:
- Create virtual environment
- Install all dependencies
- Start the service on port 5000

### 4. Test the Service

Open another terminal and test:

```bash
# Health check
curl http://localhost:5000/health

# Test AI chat
curl -X POST http://localhost:5000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Tell me about Aries",
    "conversation_history": [],
    "user_id": "test_user"
  }'
```

## 📱 Connect Flutter App

### Option 1: Local Testing

The Flutter app is already configured to use `http://localhost:5000` by default.

### Option 2: AWS Deployment

1. Deploy AI service to AWS (see AWS_DEPLOYMENT.md)
2. Update Flutter app:

```bash
flutter run --dart-define=AI_SERVICE_URL=http://your-aws-ip:5000
```

Or update `lib/core/config/env.dart`:

```dart
static const String aiServiceUrl = 'http://your-aws-ip:5000';
```

## 🎯 API Endpoints

### Main Chat Endpoint
```
POST /api/chat
Body: {
  "message": "Your question",
  "conversation_history": [],
  "user_id": "user123"
}
```

### Specialized Endpoints
- `/api/astrology` - Astrology queries
- `/api/numerology` - Numerology calculations
- `/api/vastu` - Vastu Shastra guidance
- `/api/astronomy` - Astronomy and Nakshatra info

## 🔧 Configuration

Edit `.env` file:

```bash
PORT=5000
DEBUG=False
```

## 📚 Next Steps

1. **Deploy to AWS**: See `AWS_DEPLOYMENT.md`
2. **Add More Knowledge**: Edit `knowledge_base.json`
3. **Customize Responses**: Modify `services/ai_model.py`
4. **Scale**: Use AWS ECS or Auto Scaling

## 🆘 Troubleshooting

### Port Already in Use
```bash
# Find and kill process on port 5000
lsof -ti:5000 | xargs kill -9
```

### Dependencies Error
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### Service Not Responding
```bash
# Check logs
tail -f logs/app.log

# Restart service
./start.sh
```

## ✅ Success!

If you see:
```json
{"status": "healthy", "service": "Vedic Mate AI Service"}
```

Your AI service is running! 🎉

